#!/bin/sh

echo "=========================================="
echo "Redis IMDB Setup: Starting..."
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Create ACL file with initial config if it doesn't exist
if [ ! -f /data/users.acl ]; then
    cat > /data/users.acl <<'ACL_EOF'
user default on nopass ~* +@all
ACL_EOF
fi

# Create Redis users for gRPC Auth, User and Movies Service
echo "Creating Redis users..."

# Create user for gRPC Auth Service
redis-cli ACL SETUSER "${REDIS_AUTH_USER}" on ">${REDIS_AUTH_PASSWORD}" "~*" "&${REDIS_AUTH_DB}" "+@all"
echo "${GREEN}✓ Auth user created successfully!${NC}"

# Create user for gRPC User Service
redis-cli ACL SETUSER "${REDIS_USER_USER}" on ">${REDIS_USER_PASSWORD}" "~*" "&${REDIS_USER_DB}" "+@all"
echo "${GREEN}✓ User user created successfully!${NC}"

# Create user for gRPC Movies Service
redis-cli ACL SETUSER "${REDIS_MOVIES_USER}" on ">${REDIS_MOVIES_PASSWORD}" "~*" "&${REDIS_MOVIES_DB}" "+@all"
echo "${GREEN}✓ Movies user created successfully!${NC}"

# SAVE FIRST - while default user is still enabled
redis-cli ACL SAVE
echo "Users saved to ACL file."

# NOW disable default user
redis-cli ACL SETUSER default off

# Save again with authentication
redis-cli --user "${REDIS_AUTH_USER}" -a "${REDIS_AUTH_PASSWORD}" --no-auth-warning ACL SAVE

echo "Users created successfully!"

echo ""
echo "=========================================="
echo -e "${GREEN}Redis Setup: Complete!${NC}"
echo "=========================================="