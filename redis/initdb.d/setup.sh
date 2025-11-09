#!/bin/sh

# Create ACL file with initial config if it doesn't exist
if [ ! -f /data/users.acl ]; then
    cat > /data/users.acl <<'ACL_EOF'
user default on nopass ~* +@all
ACL_EOF
fi

# Create Redis users for gRPC Auth, User and Movies Service
echo "Creating Redis users..."

redis-cli ACL SETUSER "${REDIS_AUTH_USER}" on ">${REDIS_AUTH_PASSWORD}" "~*" "&${REDIS_AUTH_DB}" "+@all"
redis-cli ACL SETUSER "${REDIS_USER_USER}" on ">${REDIS_USER_PASSWORD}" "~*" "&${REDIS_USER_DB}" "+@all"
redis-cli ACL SETUSER "${REDIS_MOVIES_USER}" on ">${REDIS_MOVIES_PASSWORD}" "~*" "&${REDIS_MOVIES_DB}" "+@all"

# SAVE FIRST - while default user is still enabled
redis-cli ACL SAVE

# NOW disable default user
redis-cli ACL SETUSER default off

# Save again with authentication
redis-cli --user "${REDIS_AUTH_USER}" -a "${REDIS_AUTH_PASSWORD}" --no-auth-warning ACL SAVE

echo "Users created successfully!"