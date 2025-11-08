@echo off

REM Copy SQl initialization files from Auth microservice to the postgres directory
if exist ".\auth\sql\create_tables.sql" copy ".\auth\sql\create_tables.sql" ".\postgres\auth_create_tables.sql"
if exist ".\auth\sql\create_functions.sql" copy ".\auth\sql\create_functions.sql" ".\postgres\auth_create_functions.sql"
if exist ".\auth\sql\create_stored_procedures.sql" copy ".\auth\sql\create_stored_procedures.sql" ".\postgres\auth_create_stored_procedures.sql"

REM Copy SQL initialization files from User microservice to the postgres directory
if exist ".\user\sql\create_tables.sql" copy ".\user\sql\create_tables.sql" ".\postgres\user_create_tables.sql"
if exist ".\user\sql\create_functions.sql" copy ".\user\sql\create_functions.sql" ".\postgres\user_create_functions.sql"
if exist ".\user\sql\create_stored_procedures.sql" copy ".\user\sql\create_stored_procedures.sql" ".\postgres\user_create_stored_procedures.sql"

echo SQL initialization files prepared for Docker.