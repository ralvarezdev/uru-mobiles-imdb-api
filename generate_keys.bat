@echo off

REM Check if OpenSSL is installed
where openssl >nul 2>&1
if errorlevel 1 (
    echo Error: OpenSSL is not installed or not found in PATH.
    exit /b 1
)

REM Generate JWT keys using OpenSSL
echo Generating JWT Ed25519 key pair...
openssl genpkey -algorithm ed25519 -out jwt_private_key.pem
openssl pkey -in jwt_private_key.pem -pubout -out jwt_public_key.pem
echo Keys generated: jwt_private_key.pem and jwt_public_key.pem"