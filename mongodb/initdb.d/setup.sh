#!/bin/bash
set -e

echo "=========================================="
echo "MongoDB IMDB Setup: Starting..."
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Create users for Internal File Storage and Movies databases
mongosh <<EOF
use ${INTERNAL_FILE_STORAGE_MONGODB_DB}
db.createUser({
  user: "${INTERNAL_FILE_STORAGE_MONGODB_USERNAME}",
  pwd: "${INTERNAL_FILE_STORAGE_MONGODB_PASSWORD}",
  roles: [{ role: "dbOwner", db: "${INTERNAL_FILE_STORAGE_MONGODB_DB}" }]
})

use ${MOVIES_MONGODB_DB}
db.createUser({
  user: "${MOVIES_MONGODB_USERNAME}",
  pwd: "${MOVIES_MONGODB_PASSWORD}",
  roles: [{ role: "dbOwner", db: "${MOVIES_MONGODB_DB}" }]
})
EOF

echo ""
echo "=========================================="
echo -e "${GREEN}MongoDB Setup: Complete!${NC}"
echo "=========================================="