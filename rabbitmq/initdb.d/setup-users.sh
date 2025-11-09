#!/bin/bash
set -e

echo "Creating users..."

rabbitmqctl add_user "${RABBITMQ_AUTH_USER}" "${RABBITMQ_AUTH_PASSWORD}" || true
rabbitmqctl set_user_tags "${RABBITMQ_AUTH_USER}" auth
rabbitmqctl set_permissions -p "${RABBITMQ_DEFAULT_VHOST}" "${RABBITMQ_AUTH_USER}" "^${RABBITMQ_TOKEN_ECHANGE_NAME}$" "^${RABBITMQ_TOKEN_ECHANGE_NAME}$" "^$"

rabbitmqctl add_user "${RABBITMQ_USER_USER}" "${RABBITMQ_USER_PASSWORD}" || true
rabbitmqctl set_user_tags "${RABBITMQ_USER_USER}" user
rabbitmqctl set_permissions -p "${RABBITMQ_DEFAULT_VHOST}" "${RABBITMQ_USER_USER}" "^$" "^$" "^${RABBITMQ_TOKEN_ECHANGE_NAME}$"

rabbitmqctl add_user "${RABBITMQ_MOVIES_USER}" "${RABBITMQ_MOVIES_PASSWORD}" || true
rabbitmqctl set_user_tags "${RABBITMQ_MOVIES_USER}" user
rabbitmqctl set_permissions -p "${RABBITMQ_DEFAULT_VHOST}" "${RABBITMQ_MOVIES_USER}" "^$" "^$" "^(${RABBITMQ_TOKEN_ECHANGE_NAME}|${RABBITMQ_USER_EXCHANGE_NAME})$"

echo "Setup complete!"