#!/bin/bash

set -e

echo "🚀 Starting Kafka with KRaft mode"
echo "=================================="

# Format storage for KRaft (only first time)
echo "📦 Formatting storage..."
kafka-storage format -t ${CLUSTER_ID} -c /etc/kafka/server.properties --ignore-formatted || true

# Start Kafka in the background
echo "🔧 Starting Kafka broker..."
/etc/confluent/docker/run &
KAFKA_PID=$!

# Wait for Kafka to be ready
echo "⏳ Waiting for Kafka to be ready..."
MAX_WAIT=60
ELAPSED=0

until kafka-broker-api-versions --bootstrap-server localhost:9092 > /dev/null 2>&1; do
    if [ $ELAPSED -ge $MAX_WAIT ]; then
        echo "❌ Timeout waiting for Kafka"
        exit 1
    fi
    echo "   Still waiting... (${ELAPSED}s)"
    sleep 5
    ELAPSED=$((ELAPSED + 5))
done

echo "Kafka is ready!"

# Create topics
echo ""
echo "Creating topics..."

# Create usernames.events (user service and movies service partitions)
kafka-topics --create \
  --bootstrap-server localhost:9092 \
  --topic usernames.events \
  --partitions 2 \
  --replication-factor 1 \
  --config retention.ms=-1 \
  --config compression.type=lz4 \
  --config min.insync.replicas=1 \
  --if-not-exists && echo "Created usernames.events"

# Create tokens.events (user service and movies service partitions)
kafka-topics --create \
  --bootstrap-server localhost:9092 \
  --topic tokens.events \
  --partitions 2 \
  --replication-factor 1 \
  --config retention.ms=-1 \
  --config compression.type=lz4 \
  --config min.insync.replicas=1 \
  --if-not-exists && echo "Created tokens.events"

# List all topics
echo ""
echo "Available topics:"
kafka-topics --list --bootstrap-server localhost:9092

echo ""
echo "Setup complete! Kafka is running with topics ready."
echo ""

# Keep Kafka running in foreground
wait $KAFKA_PID