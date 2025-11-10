#!/bin/bash

# Determine Host Architecture
HOST_ARCH=$(uname -m)
KDB_ARCH_TAG="latest" # Default for x86/amd64 systems on KurrentDB Docker image

# Check for 64-bit ARM (Raspberry Pi 3/4/5 running 64-bit OS)
if [ "$HOST_ARCH" = "aarch64" ] || [ "$HOST_ARCH" = "arm64" ]; then
  # Use the specific ARM tag you identified for KurrentDB image (must be updated if a different tag is available)
  KDB_ARCH_TAG="25.1.0-experimental-arm64-8.0-jammy"
  echo "Host architecture detected as ARM64. Using tag: $KDB_ARCH_TAG"

# Check for 32-bit ARM (Older Raspberry Pi or 32-bit OS)
elif [[ "$HOST_ARCH" == arm* ]]; then
  # If a 32-bit ARM tag exists, use it here (e.g., "experimental-arm32v7")
  # For now, we'll let it default to 'latest' if no 32-bit tag is explicitly known.
  echo "Host architecture detected as 32-bit ARM. Falling back to default tag: $KDB_ARCH_TAG (Check if a 32-bit tag is needed)."

# Default is x86/amd64
else
  echo "Host architecture detected as x86/amd64. Using default tag: $KDB_ARCH_TAG"
fi

# Execute Docker Compose with the dynamically set variable
KDB_ARCH_TAG=$KDB_ARCH_TAG docker compose up -d --build