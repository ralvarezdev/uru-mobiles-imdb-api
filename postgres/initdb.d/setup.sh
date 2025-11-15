#!/bin/bash

echo "=========================================="
echo "Postgres IMDB Setup: Starting..."
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Create Auth DB and its user
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_SUPERUSER_NAME" <<-EOSQL
    CREATE USER "$POSTGRES_AUTH_DB_USER" WITH PASSWORD '$POSTGRES_AUTH_DB_PASSWORD';
    CREATE DATABASE "$POSTGRES_AUTH_DB_NAME" OWNER "$POSTGRES_AUTH_DB_USER";
    GRANT ALL PRIVILEGES ON DATABASE "$POSTGRES_AUTH_DB_NAME" TO "$POSTGRES_AUTH_DB_USER";
EOSQL
echo -e "${GREEN}✓ Auth database and user created successfully!${NC}"

# Run the schema for the specific database
files=(./docker-entrypoint-initdb.d/sql/auth_*.sql)
if [ -e "${files[0]}" ]; then
  for file in "${files[@]}"; do
    echo "Found SQL file: $file"
    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_SUPERUSER_NAME" -d "$POSTGRES_AUTH_DB_NAME" -f "$file"
    echo -e "${GREEN}✓ Executed $file successfully!${NC}"
  done
else
  echo "No SQL files found matching pattern."
fi

# Ensure the user has privileges on all tables in the public schema
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_SUPERUSER_NAME" -d "$POSTGRES_AUTH_DB_NAME" -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"$POSTGRES_AUTH_DB_USER\";"
echo -e "${GREEN}✓ Granted privileges on all tables in auth database!${NC}"

# Ensure the user has privileges on all sequences in the public schema
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_SUPERUSER_NAME" -d "$POSTGRES_AUTH_DB_NAME" -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO \"$POSTGRES_AUTH_DB_USER\";"
echo -e "${GREEN}✓ Granted privileges on all sequences in auth database!${NC}"

# Create User DB and its user
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_SUPERUSER_NAME" <<-EOSQL
    CREATE USER "$POSTGRES_USER_DB_USER" WITH PASSWORD '$POSTGRES_USER_DB_PASSWORD';
    CREATE DATABASE "$POSTGRES_USER_DB_NAME" OWNER "$POSTGRES_USER_DB_USER";
    GRANT ALL PRIVILEGES ON DATABASE "$POSTGRES_USER_DB_NAME" TO "$POSTGRES_USER_DB_USER";
EOSQL
echo -e "${GREEN}✓ User database and user created successfully!${NC}"

# Run the schema for the specific database
files=(./docker-entrypoint-initdb.d/sql/user_*.sql)
if [ -e "${files[0]}" ]; then
  for file in "${files[@]}"; do
    echo "Found SQL file: $file"
    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_SUPERUSER_NAME" -d "$POSTGRES_USER_DB_NAME" -f "$file"
    echo -e "${GREEN}✓ Executed $file successfully!${NC}"
  done
else
  echo "No SQL files found matching pattern."
fi

# Ensure the user has privileges on all tables in the public schema
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_SUPERUSER_NAME" -d "$POSTGRES_USER_DB_NAME" -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"$POSTGRES_USER_DB_USER\";"
echo -e "${GREEN}✓ Granted privileges on all tables in user database!${NC}"

# Ensure the user has privileges on all sequences in the public schema
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_SUPERUSER_NAME" -d "$POSTGRES_USER_DB_NAME" -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO \"$POSTGRES_USER_DB_USER\";"
echo -e "${GREEN}✓ Granted privileges on all sequences in user database!${NC}"

# Create Movies DB and its user
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_SUPERUSER_NAME" <<-EOSQL
    CREATE USER "$POSTGRES_MOVIES_DB_USER" WITH PASSWORD '$POSTGRES_MOVIES_DB_PASSWORD';
    CREATE DATABASE "$POSTGRES_MOVIES_DB_NAME" OWNER "$POSTGRES_MOVIES_DB_USER";
    GRANT ALL PRIVILEGES ON DATABASE "$POSTGRES_MOVIES_DB_NAME" TO "$POSTGRES_MOVIES_DB_USER";
EOSQL
echo -e "${GREEN}✓ Movies database and user created successfully!${NC}"

# Run the schema for the specific database
files=(./docker-entrypoint-initdb.d/sql/movies_*.sql)
if [ -e "${files[0]}" ]; then
  for file in "${files[@]}"; do
    echo "Found SQL file: $file"
    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_SUPERUSER_NAME" -d "$POSTGRES_MOVIES_DB_NAME" -f "$file"
    echo -e "${GREEN}✓ Executed $file successfully!${NC}"
  done
else
  echo "No SQL files found matching pattern."
fi

# Ensure the user has privileges on all tables in the public schema
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_SUPERUSER_NAME" -d "$POSTGRES_MOVIES_DB_NAME" -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"$POSTGRES_MOVIES_DB_USER\";"
echo -e "${GREEN}✓ Granted privileges on all tables in movies database!${NC}"

# Ensure the user has privileges on all sequences in the public schema
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_SUPERUSER_NAME" -d "$POSTGRES_MOVIES_DB_NAME" -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO \"$POSTGRES_MOVIES_DB_USER\";"
echo -e "${GREEN}✓ Granted privileges on all sequences in movies database!${NC}"

echo ""
echo "=========================================="
echo -e "${GREEN}Postgres Setup: Complete!${NC}"
echo "=========================================="