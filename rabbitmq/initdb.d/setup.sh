#!/bin/bash
set -e

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
rabbitmqctl set_permissions -p "${RABBITMQ_DEFAULT_VHOST}" "${RABBITMQ_AUTH_USER}" "^(${RABBITMQ_TOKENS_EXCHANGE_NAME}${RABBITMQ_USERNAMES_EXCHANGE_NAME}|${RABBITMQ_MAILS_EXCHANGE_NAME}$)$" "^(${RABBITMQ_TOKENS_EXCHANGE_NAME}${RABBITMQ_USERNAMES_EXCHANGE_NAME}|${RABBITMQ_MAILS_EXCHANGE_NAME}$)$" "^$"
echo "${GREEN}✓ Auth user created successfully!${NC}"

# Create RabbitMQ user for gRPC User Service
rabbitmqctl add_user "${RABBITMQ_USER_USER}" "${RABBITMQ_USER_PASSWORD}" || true
rabbitmqctl set_user_tags "${RABBITMQ_USER_USER}" user
rabbitmqctl set_permissions -p "${RABBITMQ_DEFAULT_VHOST}" "${RABBITMQ_USER_USER}" "^$" "^$" "^${RABBITMQ_TOKENS_EXCHANGE_NAME}$"
echo "${GREEN}✓ User user created successfully!${NC}"

# Create RabbitMQ user for gRPC Movies Service
rabbitmqctl add_user "${RABBITMQ_MOVIES_USER}" "${RABBITMQ_MOVIES_PASSWORD}" || true
rabbitmqctl set_user_tags "${RABBITMQ_MOVIES_USER}" movies
rabbitmqctl set_permissions -p "${RABBITMQ_DEFAULT_VHOST}" "${RABBITMQ_MOVIES_USER}" "^$" "^$" "^(${RABBITMQ_TOKENS_EXCHANGE_NAME}|${RABBITMQ_USERNAMES_EXCHANGE_NAME})$"
echo "${GREEN}✓ Movies user created successfully!${NC}"

# Create RabbitMQ user for gRPC Mailer Service
rabbitmqctl add_user "${RABBITMQ_INTERNAL_MAILER_USER}" "${RABBITMQ_INTERNAL_MAILER_PASSWORD}" || true
rabbitmqctl set_user_tags "${RABBITMQ_INTERNAL_MAILER_USER}" internal_mailer
rabbitmqctl set_permissions -p "${RABBITMQ_DEFAULT_VHOST}" "${RABBITMQ_INTERNAL_MAILER_USER}" "^$" "^$" "^${RABBITMQ_MAILS_EXCHANGE_NAME}$"
echo "${GREEN}✓ Internal Mailer user created successfully!${NC}"

echo ""
echo "=========================================="
echo -e "${GREEN}RabbitMQ Setup: Complete!${NC}"
echo "=========================================="