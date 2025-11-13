#!/bin/bash

# Create the initdb.d/sql directory if it doesn't exist
mkdir -p ./postgres/initdb.d/sql

# Copy SQL initialization files from Auth microservice to the postgres directory
for file in "./auth/sql"/*; do
    # Check if the file ends with .sql
    if [[ -f "$file" && "$file" == *.sql ]]; then
        cp "$file" "./postgres/initdb.d/sql/auth_$(basename "$file")"
    fi
done

# Copy SQL initialization files from User microservice to the postgres directory
for file in "./user/sql"/*; do
    # Check if the file ends with .sql
    if [[ -f "$file" && "$file" == *.sql ]]; then
        cp "$file" "./postgres/initdb.d/sql/user_$(basename "$file")"
    fi
done

# Ensure SQL files can be read by Docker
chmod a+r ./postgres/initdb.d/sql/*.sql
echo "SQL initialization files prepared for Docker."