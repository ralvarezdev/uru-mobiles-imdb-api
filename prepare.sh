#!/bin/sh

# Create the initdb.d/sql directory if it doesn't exist
mkdir -p ./postgres/initdb.d/sql

# Create the folders if they don't exist
mkdir -p ./auth/sql
mkdir -p ./user/sql
mkdir -p ./movies/sql

# Copy SQL initialization files from Auth microservice to the postgres directory
for file in ./auth/sql/*.sql; do
    if [ -f "$file" ]; then
        cp "$file" "./postgres/initdb.d/sql/auth_$(basename "$file")"
    fi
done

# Copy SQL initialization files from User microservice to the postgres directory
for file in ./user/sql/*.sql; do
    if [ -f "$file" ]; then
        cp "$file" "./postgres/initdb.d/sql/user_$(basename "$file")"
    fi
done

# Copy SQL initialization files from Movies microservice to the postgres directory
for file in ./movies/sql/*.sql; do
    if [ -f "$file" ]; then
        cp "$file" "./postgres/initdb.d/sql/movies_$(basename "$file")"
    fi
done

# Ensure SQL files can be read
chmod a+r ./postgres/initdb.d/sql/*.sql
echo "SQL initialization files prepared."