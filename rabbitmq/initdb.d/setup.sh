#!/bin/sh

echo "=========================================="
echo "RabbitMQ IMDB Setup: Starting..."
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "${YELLOW}Creating RabbitMQ users...${NC}"

# Create RabbitMQ user for gRPC Auth Service
rabbitmqctl add_user "${RABBITMQ_AUTH_USER}" "${RABBITMQ_AUTH_PASSWORD}" || true
rabbitmqctl set_user_tags "${RABBITMQ_AUTH_USER}" auth
rabbitmqctl set_permissions -p "${RABBITMQ_DEFAULT_VHOST}" "${RABBITMQ_AUTH_USER}" "^${RABBITMQ_MAILS_EXCHANGE_NAME}$" "^${RABBITMQ_MAILS_EXCHANGE_NAME}$" "^$"
echo "${GREEN}✓ Auth user created successfully!${NC}"

# Create RabbitMQ user for gRPC Mailer Service
rabbitmqctl add_user "${RABBITMQ_INTERNAL_MAILER_USER}" "${RABBITMQ_INTERNAL_MAILER_PASSWORD}" || true
rabbitmqctl set_user_tags "${RABBITMQ_INTERNAL_MAILER_USER}" internal_mailer
rabbitmqctl set_permissions -p "${RABBITMQ_DEFAULT_VHOST}" "${RABBITMQ_INTERNAL_MAILER_USER}" "^(${RABBITMQ_MAILS_EXCHANGE_NAME}|${RABBITMQ_MAILS_QUEUES}.*)$" "^(${RABBITMQ_MAILS_EXCHANGE_NAME}|${RABBITMQ_MAILS_QUEUES}.*)$" "^${RABBITMQ_MAILS_QUEUES}.*$"
echo "${GREEN}✓ Internal Mailer user created successfully!${NC}"

echo ""
echo "=========================================="
echo "${GREEN}RabbitMQ Setup: Complete!${NC}"
echo "=========================================="