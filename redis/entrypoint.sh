#!/bin/sh
set -e

# Check if initialization is needed
if [ -f /data/.initialized ]; then
    echo "Already initialized, skipping init scripts..."
else
    echo "First run detected, initializing..."
    
    # Create ACL file with initial config if it doesn't exist
    if [ ! -f /data/users.acl ]; then
        cat > /data/users.acl <<ACL_EOF
user default on >${REDIS_DEFAULT_PASSWORD} ~* +@all
ACL_EOF
        echo "Created initial ACL file with default user."
    fi
    
    # Start Redis in background WITH ACL file configured
    redis-server --daemonize yes --protected-mode no --aclfile /data/users.acl
    
    # Wait for Redis to be ready
    until redis-cli ping 2>/dev/null; do
      echo "Waiting for Redis..."
      sleep 1
    done
    
    echo "Redis is ready, running init scripts..."
    
    # Run all scripts in initdb.d directory
    for script in /docker-entrypoint-initdb.d/*.sh; do
      if [ -f "$script" ]; then
        echo "Running $script..."
        sh "$script"
      fi
    done
    
    echo "Initialization complete"
    
    # Stop background Redis
    redis-cli -a "${REDIS_DEFAULT_PASSWORD}" --no-auth-warning shutdown nosave
    
    # Wait for shutdown
    sleep 2
    
    # Create flag file
    touch /data/.initialized
fi

# Start Redis normally with ACL file
exec redis-server --aclfile /data/users.acl