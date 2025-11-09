#!/bin/sh
set -e

echo "Creating Redis users..."

# Create initial ACL structure with default user
redis-cli -h redis <<EOF
ACL SETUSER default on nopass ~* +@all
ACL SAVE
EOF

echo "Initial ACL file created"

# Create Auth service user
redis-cli -h redis ACL SETUSER "${REDIS_AUTH_USER}" \
  on \
  ">${REDIS_AUTH_PASSWORD}" \
  ~* \
  "&${REDIS_AUTH_DB}" \
  +@all

echo "Created user: ${REDIS_AUTH_USER} (DB ${REDIS_AUTH_DB})"

# Create User service user
redis-cli -h redis ACL SETUSER "${REDIS_USER_USER}" \
  on \
  ">${REDIS_USER_PASSWORD}" \
  ~* \
  "&${REDIS_USER_DB}" \
  +@all

echo "Created user: ${REDIS_USER_USER} (DB ${REDIS_USER_DB})"

# Create Movies service user
redis-cli -h redis ACL SETUSER "${REDIS_MOVIES_USER}" \
  on \
  ">${REDIS_MOVIES_PASSWORD}" \
  ~* \
  "&${REDIS_MOVIES_DB}" \
  +@all

echo "Created user: ${REDIS_MOVIES_USER} (DB ${REDIS_MOVIES_DB})"

# Save ACL configuration
redis-cli -h redis ACL SAVE
echo "ACL configuration saved"

# Disable default user for security
echo "Disabling default user..."
redis-cli -h redis --user "${REDIS_AUTH_USER}" -a "${REDIS_AUTH_PASSWORD}" --no-auth-warning \
  ACL SETUSER default off

redis-cli -h redis --user "${REDIS_AUTH_USER}" -a "${REDIS_AUTH_PASSWORD}" --no-auth-warning \
  ACL SAVE

echo "Default user disabled"

# Show configured users
echo ""
echo "📋 Configured users:"
redis-cli -h redis --user "${REDIS_AUTH_USER}" -a "${REDIS_AUTH_PASSWORD}" --no-auth-warning \
  ACL LIST

echo ""
echo "=========================================="
echo "User creation complete!"
echo "=========================================="