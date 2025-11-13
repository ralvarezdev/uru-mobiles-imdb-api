#!/bin/sh

echo "=========================================="
echo "Redis IMDB Setup: Starting..."
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Create Redis users for gRPC Auth, User and Movies Service
echo "Creating Redis users..."

# Create user for gRPC Auth Service
(echo "AUTH ${REDIS_DEFAULT_PASSWORD}"; echo "ACL SETUSER ${REDIS_AUTH_USER} on >${REDIS_AUTH_PASSWORD} ~* &${REDIS_TOKENS_DB} +@read +@write") | redis-cli
echo "${GREEN}✓ Auth service created successfully!${NC}"

# Create user for gRPC User Service
(echo "AUTH ${REDIS_DEFAULT_PASSWORD}"; echo "ACL SETUSER ${REDIS_USER_USER} on >${REDIS_USER_PASSWORD} ~* &${REDIS_TOKENS_DB} +@read") | redis-cli
echo "${GREEN}✓ User service created successfully!${NC}"

# Create user for gRPC Movies Service
(echo "AUTH $REDIS_DEFAULT_PASSWORD"; echo "ACL SETUSER ${REDIS_MOVIES_USER} on >${REDIS_MOVIES_PASSWORD} ~* &${REDIS_TOKENS_DB} +@read") | redis-cli
echo "${GREEN}✓ Movies service created successfully!${NC}"

# Save again with root authentication
redis-cli -a "${REDIS_DEFAULT_PASSWORD}" --no-auth-warning ACL SAVE
echo "Users saved to ACL file."

echo "Users created successfully!"

echo ""
echo "=========================================="
echo "${GREEN}Redis Setup: Complete!${NC}"
echo "=========================================="