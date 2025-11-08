#!/bin/bash
set -e

# Create Auth DB and user
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_SUPERUSER_NAME" <<-EOSQL
    CREATE USER "$POSTGRES_AUTH_DB_USER" WITH PASSWORD '$POSTGRES_AUTH_DB_PASSWORD';
    CREATE DATABASE "$POSTGRES_AUTH_DB_NAME" OWNER "$POSTGRES_AUTH_DB_USER";
    GRANT ALL PRIVILEGES ON DATABASE "$POSTGRES_AUTH_DB_NAME" TO "$POSTGRES_AUTH_DB_USER";
EOSQL

# Run the schema for the specific database
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_SUPERUSER_NAME" -d "$POSTGRES_AUTH_DB_NAME" -f /docker-entrypoint-initdb.d/sql/auth_create_tables.sql
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_SUPERUSER_NAME" -d "$POSTGRES_AUTH_DB_NAME" -f /docker-entrypoint-initdb.d/sql/auth_create_functions.sql
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_SUPERUSER_NAME" -d "$POSTGRES_AUTH_DB_NAME" -f /docker-entrypoint-initdb.d/sql/auth_create_stored_procedures.sql

# Ensure the user has privileges on all tables in the public schema
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_SUPERUSER_NAME" -d "$POSTGRES_AUTH_DB_NAME" -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"$POSTGRES_AUTH_DB_USER\";"

# Ensure the user has privileges on all sequences in the public schema
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_SUPERUSER_NAME" -d "$POSTGRES_AUTH_DB_NAME" -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO \"$POSTGRES_AUTH_DB_USER\";"

# Create Recipes DB and User
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_SUPERUSER_NAME" <<-EOSQL
    CREATE USER "$POSTGRES_USER_DB_USER" WITH PASSWORD '$POSTGRES_USER_DB_PASSWORD';
    CREATE DATABASE "$POSTGRES_USER_DB_NAME" OWNER "$POSTGRES_USER_DB_USER";
    GRANT ALL PRIVILEGES ON DATABASE "$POSTGRES_USER_DB_NAME" TO "$POSTGRES_USER_DB_USER";
EOSQL

# Run the schema for the specific database
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_SUPERUSER_NAME" -d "$POSTGRES_USER_DB_NAME" -f /docker-entrypoint-initdb.d/sql/user_create_tables.sql
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_SUPERUSER_NAME" -d "$POSTGRES_USER_DB_NAME" -f /docker-entrypoint-initdb.d/sql/user_create_functions.sql
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_SUPERUSER_NAME" -d "$POSTGRES_USER_DB_NAME" -f /docker-entrypoint-initdb.d/sql/user_create_stored_procedures.sql

# Ensure the user has privileges on all tables in the public schema
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_SUPERUSER_NAME" -d "$POSTGRES_USER_DB_NAME" -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"$POSTGRES_USER_DB_USER\";"

# Ensure the user has privileges on all sequences in the public schema
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_SUPERUSER_NAME" -d "$POSTGRES_USER_DB_NAME" -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO \"$POSTGRES_USER_DB_USER\";"