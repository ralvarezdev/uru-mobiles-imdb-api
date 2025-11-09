#!/bin/bash
set -e

echo "Starting Kafka setup..."

# Create SCRAM users
echo "Creating SCRAM users..."

kafka-configs --bootstrap-server localhost:9094 \
  --alter \
  --add-config "SCRAM-SHA-256=[iterations=8192,password=${KAFKA_AUTH_PASSWORD}]" \
  --entity-type users \
  --entity-name ${KAFKA_AUTH_USERNAME}

kafka-configs --bootstrap-server localhost:9094 \
  --alter \
  --add-config "SCRAM-SHA-256=[iterations=8192,password=${KAFKA_USER_PASSWORD}]" \
  --entity-type users \
  --entity-name ${KAFKA_USER_USERNAME}

kafka-configs --bootstrap-server localhost:9094 \
  --alter \
  --add-config "SCRAM-SHA-256=[iterations=8192,password=${KAFKA_MOVIES_PASSWORD}]" \
  --entity-type users \
  --entity-name ${KAFKA_MOVIES_USERNAME}

echo "SCRAM users created!"
echo "Users: ${KAFKA_ADMIN_USERNAME}, ${KAFKA_AUTH_USERNAME}, ${KAFKA_USER_USERNAME}, ${KAFKA_MOVIES_USERNAME}"

# Create a temporary file for Kafka client configuration
CONFIG_FILE=$(mktemp)

# Create admin config file for authenticated operations
cat > "$CONFIG_FILE" << EOF
sasl.mechanism=SCRAM-SHA-256
security.protocol=SASL_PLAINTEXT
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required username="${KAFKA_ADMIN_USERNAME}" password="${KAFKA_ADMIN_PASSWORD}";
EOF

# Wait a moment for users to propagate
sleep 2

# Create topics
echo ""
echo "Creating topics..."

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

# Auth service permissions: WRITE to topics
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

# User service permissions: READ from topics
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

# Movies service permissions: READ from topics
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

# Consumer group permissions
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
echo "=========================================="
echo "Setup complete! Kafka is ready."
echo "=========================================="
echo "Topics: usernames.events, tokens.events"
echo "Users: ${KAFKA_ADMIN_USERNAME}, ${KAFKA_AUTH_USERNAME}, ${KAFKA_USER_USERNAME}, ${KAFKA_MOVIES_USERNAME}"
echo "=========================================="
echo ""

# Keep Kafka running in foreground
wait $KAFKA_PID