#!/usr/bin/env bash

# Copy SQL initialization files from Auth microservice to the postgres directory
if [ -f "./auth/sql/create_tables.sql" ]; then
  cp "./auth/sql/create_tables.sql" "./postgres/initdb.d/sql/auth_create_tables.sql"
fi
if [ -f "./auth/sql/create_functions.sql" ]; then
  cp "./auth/sql/create_functions.sql" "./postgres/initdb.d/sql/auth_create_functions.sql"
fi
if [ -f "./auth/sql/create_stored_procedures.sql" ]; then
  cp "./auth/sql/create_stored_procedures.sql" "./postgres/initdb.d/sql/auth_create_stored_procedures.sql"
fi

# Copy SQL initialization files from User microservice to the postgres directory
if [ -f "./user/sql/create_tables.sql" ]; then
  cp "./user/sql/create_tables.sql" "./postgres/initdb.d/sql/user_create_tables.sql"
fi
if [ -f "./user/sql/create_functions.sql" ]; then
  cp "./user/sql/create_functions.sql" "./postgres/initdb.d/sql/user_create_functions.sql"
fi
if [ -f "./user/sql/create_stored_procedures.sql" ]; then
  cp "./user/sql/create_stored_procedures.sql" "./postgres/initdb.d/sql/user_create_stored_procedures.sql"
fi

# Ensure SQL files can be read by Docker
chmod a+r ./postgres/initdb.d/sql/*.sql
echo "SQL initialization files prepared for Docker."