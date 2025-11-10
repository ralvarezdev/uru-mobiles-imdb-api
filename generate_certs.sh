#!/bin/bash

# Create directory
mkdir -p ./kurrentdb/certs

# Generate certificate
openssl req -x509 -newkey rsa:2048 -nodes \
  -keyout ./kurrentdb/certs/node.key \
  -out ./kurrentdb/certs/node.crt \
  -days 3650 \
  -subj "/CN=kurrentdb"

# Verify files were created
ls -la ./kurrentdb/certs/

# Create the kurrentdb-setup certs directory
mkdir -p ./kurrentdb-setup/certs

# Copy to kurrentdb-setup
cp ./kurrentdb/certs/node.key ./kurrentdb-setup/certs/node.key
cp ./kurrentdb/certs/node.crt ./kurrentdb-setup/certs/node.crt