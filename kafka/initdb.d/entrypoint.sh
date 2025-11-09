#!/bin/bash

set -e

# Create admin credentials file for CLI tools
cat > /tmp/admin.properties << EOF
sasl.mechanism=PLAIN
security.protocol=SASL_PLAINTEXT
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="${KAFKA_ADMIN_USERNAME}" password="${KAFKA_ADMIN_PASSWORD}";
EOF

echo "Starting Kafka with KRaft mode"

# Format storage for KRaft (only first time)
echo "Formatting storage..."
kafka-storage format -t ${CLUSTER_ID} -c /etc/kafka/server.properties --ignore-formatted || true

# Start Kafka in the background
echo "Starting Kafka broker..."
/etc/confluent/docker/run &
KAFKA_PID=$!

# Wait for Kafka to be ready
echo "Waiting for Kafka to be ready..."
MAX_WAIT=60
ELAPSED=0

until kafka-broker-api-versions --bootstrap-server localhost:9092  \
    --command-config /tmp/admin.properties > /dev/null 2>&1; do
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
  --command-config /tmp/admin.properties \
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
  --command-config /tmp/admin.properties \
  --partitions 2 \
  --replication-factor 1 \
  --config retention.ms=-1 \
  --config compression.type=lz4 \
  --config min.insync.replicas=1 \
  --if-not-exists && echo "Created tokens.events"

# List all topics
echo ""
echo "Available topics:"
kafka-topics --list --bootstrap-server localhost:9092 \
  --command-config /tmp/admin.properties

# Setup ACLs
echo ""
echo "Setting up ACLs..."

# Auth service permissions: WRITE to topics (for producing usernames and tokens events)
kafka-acls --add \
  --bootstrap-server localhost:9092 \
  --command-config /tmp/admin.properties \
  --allow-principal User:${KAFKA_AUTH_USERNAME} \
  --operation Write \
  --operation Describe \
  --topic usernames.events \
  --force

kafka-acls --add \
  --bootstrap-server localhost:9092 \
  --command-config /tmp/admin.properties \
  --allow-principal User:${KAFKA_AUTH_USERNAME} \
  --operation Write \
  --operation Describe \
  --topic tokens.events \
  --force

echo "Auth service ACLs set (Write access)"

# User and movies services permissions - READ from topics (for consuming usernames and tokens events)
kafka-acls --add \
  --bootstrap-server localhost:9092 \
  --command-config /tmp/admin.properties \
  --allow-principal User:${KAFKA_USER_USERNAME} \
  --operation Read \
  --operation Describe \
  --topic usernames.events \
  --force

kafka-acls --add \
  --bootstrap-server localhost:9092 \
  --command-config /tmp/admin.properties \
  --allow-principal User:${KAFKA_USER_USERNAME} \
  --operation Read \
  --operation Describe \
  --topic tokens.events \
  --force
  
kafka-acls --add \
  --bootstrap-server localhost:9092 \
  --command-config /tmp/admin.properties \
  --allow-principal User:${KAFKA_MOVIES_USERNAME} \
  --operation Read \
  --operation Describe \
  --topic usernames.events \
  --force

kafka-acls --add \
  --bootstrap-server localhost:9092 \
  --command-config /tmp/admin.properties \
  --allow-principal User:${KAFKA_MOVIES_USERNAME} \
  --operation Read \
  --operation Describe \
  --topic tokens.events \
  --force

# Consumer group permissions (for both user and movies services)
kafka-acls --add \
  --bootstrap-server localhost:9092 \
  --command-config /tmp/admin.properties \
  --allow-principal User:${KAFKA_USER_USERNAME} \
  --operation Read \
  --group '*' \
  --force
  
kafka-acls --add \
  --bootstrap-server localhost:9092 \
  --command-config /tmp/admin.properties \
  --allow-principal User:${KAFKA_MOVIES_USERNAME} \
  --operation Read \
  --group '*' \
  --force

echo "Consumer ACLs set (Read access + Consumer groups)"

# List ACLs
echo ""
echo "Configured ACLs:"
kafka-acls --list \
  --bootstrap-server localhost:9092 \
  --command-config /tmp/admin.properties


echo ""
echo "Setup complete! Kafka is running with topics ready."
echo ""

# Keep Kafka running in foreground
wait $KAFKA_PID