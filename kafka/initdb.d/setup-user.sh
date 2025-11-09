#!/bin/bash

echo "Waiting for Kafka to be ready..."
sleep 15

# Function to check if Kafka is ready
wait_for_kafka() {
  while ! kafka-broker-api-versions --bootstrap-server kafka:9092 \
    --command-config /tmp/admin.properties > /dev/null 2>&1; do
    echo "Kafka is not ready yet. Waiting..."
    sleep 5
  done
  echo "Kafka is ready!"
}

# Create admin properties file
cat > /tmp/admin.properties << EOF
sasl.mechanism=SCRAM-SHA-256
security.protocol=SASL_PLAINTEXT
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required username="admin" password="admin-secret";
EOF

wait_for_kafka

echo "Creating Kafka users..."

# Create admin user
kafka-configs --zookeeper zookeeper:2181 \
  --alter \
  --add-config 'SCRAM-SHA-256=[password=admin-secret]' \
  --entity-type users \
  --entity-name admin

echo "✓ Admin user created"

# Create service users
declare -A USERS=(
  ["auth-client"]="auth-secret-123"
  ["user"]="user-secret-456"
  ["movies"]="movies-secret-789"
)

for user in "${!USERS[@]}"; do
  password="${USERS[$user]}"
  
  kafka-configs --zookeeper zookeeper:2181 \
    --alter \
    --add-config "SCRAM-SHA-256=[password=$password]" \
    --entity-type users \
    --entity-name "$user"
  
  echo "✓ User '$user' created"
done

echo "Creating topics..."

# Create user and token topics
kafka-topics --bootstrap-server kafka:9092 \
  --command-config /tmp/admin.properties \
  --create \
  --topic user \
  --partitions 3 \
  --replication-factor 1 \
  --if-not-exists

kafka-topics --bootstrap-server kafka:9092 \
  --command-config /tmp/admin.properties \
  --create \
  --topic token \
  --partitions 3 \
  --replication-factor 1 \
  --if-not-exists

echo "✓ Topics created"

echo "Setting up ACLs..."

# auth-client: WRITE permissions for 'user' and 'token' topics
kafka-acls --bootstrap-server kafka:9092 \
  --command-config /tmp/admin.properties \
  --add \
  --allow-principal User:auth-client \
  --operation Write \
  --topic user

kafka-acls --bootstrap-server kafka:9092 \
  --command-config /tmp/admin.properties \
  --add \
  --allow-principal User:auth-client \
  --operation Write \
  --topic token

echo "✓ auth-client WRITE permissions set"

# user: READ permissions for 'user' and 'token' topics
kafka-acls --bootstrap-server kafka:9092 \
  --command-config /tmp/admin.properties \
  --add \
  --allow-principal User:user \
  --operation Read \
  --topic user

kafka-acls --bootstrap-server kafka:9092 \
  --command-config /tmp/admin.properties \
  --add \
  --allow-principal User:user \
  --operation Read \
  --topic token

# user: READ permissions for consumer group
kafka-acls --bootstrap-server kafka:9092 \
  --command-config /tmp/admin.properties \
  --add \
  --allow-principal User:user \
  --operation Read \
  --group user-consumer-group

echo "✓ user READ permissions set"

# movies: READ permissions for 'user' and 'token' topics
kafka-acls --bootstrap-server kafka:9092 \
  --command-config /tmp/admin.properties \
  --add \
  --allow-principal User:movies \
  --operation Read \
  --topic user

kafka-acls --bootstrap-server kafka:9092 \
  --command-config /tmp/admin.properties \
  --add \
  --allow-principal User:movies \
  --operation Read \
  --topic token

# movies: READ permissions for consumer group
kafka-acls --bootstrap-server kafka:9092 \
  --command-config /tmp/admin.properties \
  --add \
  --allow-principal User:movies \
  --operation Read \
  --group movies-consumer-group

echo "✓ movies READ permissions set"