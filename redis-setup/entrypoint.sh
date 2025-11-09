set -e

# Check if already initialized
if redis-cli -h redis ACL LIST 2>/dev/null | grep -q "${REDIS_AUTH_USER}"; then
  echo "Redis already initialized, skipping setup"
  exit 0
fi

echo "First run detected, initializing Redis..."

# Run initialization scripts
for script in /docker-entrypoint-initdb.d/*.sh; do
  if [ -f "$script" ]; then
    echo "Running $(basename $script)..."
    sh "$script"
  fi
done

echo "Redis setup complete!"