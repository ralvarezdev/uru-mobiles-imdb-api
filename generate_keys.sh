#!/bin/sh

# Create the JWT keys directory if it doesn't exist
mkdir -p ./jwt/keys

# Check if OpenSSL is installed
if ! command -v openssl >/dev/null 2>&1; then
    echo "Error: OpenSSL is not installed or not found in PATH."
    exit 1
fi

# Generate JWT keys using OpenSSL
echo "Generating JWT Ed25519 key pair..."
openssl genpkey -algorithm ed25519 -out jwt/keys/private_key.pem
openssl pkey -in jwt/keys/private_key.pem -pubout -out jwt/keys/public_key.pem
echo "Keys generated: jwt/keys/private_key.pem and jwt/keys/public_key.pem"