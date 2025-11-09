#!/bin/bash
# 
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
