#!/bin/bash
set -e

echo "Creating users..."

rabbitmqctl add_user "${RABBITMQ_AUTH_USER}" "${RABBITMQ_AUTH_PASSWORD}" || true
rabbitmqctl set_user_tags "${RABBITMQ_AUTH_USER}" auth
rabbitmqctl set_permissions -p "${RABBITMQ_DEFAULT_VHOST}" "${RABBITMQ_AUTH_USER}" "^(${RABBITMQ_TOKENS_EXCHANGE_NAME}${RABBITMQ_USERNAMES_EXCHANGE_NAME}|${RABBITMQ_MAILS_EXCHANGE_NAME}$)$" "^(${RABBITMQ_TOKENS_EXCHANGE_NAME}${RABBITMQ_USERNAMES_EXCHANGE_NAME}|${RABBITMQ_MAILS_EXCHANGE_NAME}$)$" "^$"

rabbitmqctl add_user "${RABBITMQ_USER_USER}" "${RABBITMQ_USER_PASSWORD}" || true
rabbitmqctl set_user_tags "${RABBITMQ_USER_USER}" user
rabbitmqctl set_permissions -p "${RABBITMQ_DEFAULT_VHOST}" "${RABBITMQ_USER_USER}" "^$" "^$" "^${RABBITMQ_TOKENS_EXCHANGE_NAME}$"

rabbitmqctl add_user "${RABBITMQ_MOVIES_USER}" "${RABBITMQ_MOVIES_PASSWORD}" || true
rabbitmqctl set_user_tags "${RABBITMQ_MOVIES_USER}" movies
rabbitmqctl set_permissions -p "${RABBITMQ_DEFAULT_VHOST}" "${RABBITMQ_MOVIES_USER}" "^$" "^$" "^(${RABBITMQ_TOKENS_EXCHANGE_NAME}|${RABBITMQ_USERNAMES_EXCHANGE_NAME})$"

rabbitmqctl add_user "${RABBITMQ_INTERNAL_MAILER_USER}" "${RABBITMQ_INTERNAL_MAILER_PASSWORD}" || true
rabbitmqctl set_user_tags "${RABBITMQ_INTERNAL_MAILER_USER}" internal_mailer
rabbitmqctl set_permissions -p "${RABBITMQ_DEFAULT_VHOST}" "${RABBITMQ_INTERNAL_MAILER_USER}" "^$" "^$" "^${RABBITMQ_MAILS_EXCHANGE_NAME}$"

echo "Setup complete!"