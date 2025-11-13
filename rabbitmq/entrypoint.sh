#!/bin/sh

# Check if RabbitMQ data actually exists (not just the marker file)
if [ ! -d "/var/lib/rabbitmq/mnesia" ] || [ -z "$(ls -A /var/lib/rabbitmq/mnesia 2>/dev/null)" ]; then
    echo "First run or data missing, initializing..."
    
    # Remove old marker if it exists
    rm -f /var/lib/rabbitmq/.initialized
    
    # Start RabbitMQ in background
    rabbitmq-server -detached
    
    # Wait for RabbitMQ to be ready
    echo "Waiting for RabbitMQ to start..."
    until rabbitmqctl await_startup; do
      sleep 1
    done
    
    echo "RabbitMQ is ready, running init scripts..."
    
    # Run all scripts in initdb.d directory
    for script in /docker-entrypoint-initdb.d/*.sh; do
      if [ -f "$script" ]; then
        echo "Running $script..."
        sh "$script"
      fi
    done
    
    echo "Initialization complete"
    
    # Stop the detached RabbitMQ gracefully
    echo "Stopping RabbitMQ to restart in foreground..."
    rabbitmqctl stop_app
    rabbitmqctl stop
    
    # Mark as initialized
    touch /var/lib/rabbitmq/.initialized
    
    echo "Starting RabbitMQ in foreground..."
else
    echo "Already initialized, skipping init scripts..."
fi

# Always start RabbitMQ in foreground
exec rabbitmq-server