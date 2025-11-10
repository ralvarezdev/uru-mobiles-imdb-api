#!/bin/bash
set -e

echo "=========================================="
echo "KurrentDB IMDB Setup: Starting..."
echo "=========================================="

# Configuration
MAX_RETRIES=30
RETRY_INTERVAL=2

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Wait for KurrentDB
echo "Waiting for KurrentDB to be ready..."
for i in $(seq 1 $MAX_RETRIES); do
    if curl $CURL_OPTS -sf -u "$KURRENTDB_ADMIN_USERNAME:$KURRENTDB_ADMIN_PASSWORD" "$KURRENTDB_SCHEME://$KURRENTDB_HOST:$KURRENTDB_PORT/gossip" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ KurrentDB is ready!${NC}"
        break
    fi
    
    if [ $i -eq $MAX_RETRIES ]; then
        echo -e "${RED}✗ ERROR: KurrentDB did not become ready in time${NC}"
        exit 1
    fi
    
    echo "Waiting for KurrentDB... (attempt $i/$MAX_RETRIES)"
    sleep $RETRY_INTERVAL
done

echo ""

# Function to create a user
create_user() {
    local login_name=$1
    local full_name=$2
    local password=$3
    local groups=$4
    
    echo -n "Creating user: $login_name... "
    
    local payload=$(jq -n \
        --arg login "$login_name" \
        --arg full "$full_name" \
        --arg pass "$password" \
        --arg grps "$groups" \
        '{
            loginName: $login,
            fullName: $full,
            password: $pass,
            groups: ($grps | split(",") | map(select(. != "")))
        }')
    
    local response=$(curl $CURL_OPTS -s -w "\n%{http_code}" -X POST \
        "$KURRENTDB_SCHEME://$KURRENTDB_HOST:$KURRENTDB_PORT/users/" \
        -H "Content-Type: application/json" \
        -u "$KURRENTDB_ADMIN_USERNAME:$KURRENTDB_ADMIN_PASSWORD" \
        -d "$payload")
    
    local http_code=$(echo "$response" | tail -n1)
    
    if [ "$http_code" = "201" ]; then
        echo -e "${GREEN}✓ Created${NC}"
    elif [ "$http_code" = "409" ]; then
        echo -e "${YELLOW}⚠ Already exists${NC}"
    else
        echo -e "${RED}✗ Failed (HTTP $http_code)${NC}"
    fi
}

# Function to create stream
create_stream() {
    local stream=$1
    
    local payload='[{
        "eventId": "00000000-0000-0000-0000-000000000000",
        "eventType": "StreamCreated",
        "data": {}
    }]'
    
    curl $CURL_OPTS -s -X POST \
        "$KURRENTDB_SCHEME://$KURRENTDB_HOST:$KURRENTDB_PORT/streams/$stream" \
        -H "Content-Type: application/vnd.eventstore.events+json" \
        -u "$KURRENTDB_ADMIN_USERNAME:$KURRENTDB_ADMIN_PASSWORD" \
        -d "$payload" > /dev/null 2>&1
}

# Function to set stream ACL
set_stream_acl() {
    local stream=$1
    local readers=$2
    local writers=$3
    
    echo ""
    echo "Stream: $stream"
    echo "  Read: $readers"
    echo "  Write: $writers"
    
    # Create stream first
    echo -n "  Creating stream... "
    create_stream "$stream"
    echo -e "${GREEN}✓${NC}"
    
    echo -n "  Setting ACL... "
    
    # Convert to arrays
    local readers_json=$(echo "$readers" | jq -R 'split(",") | map(select(length > 0))')
    local writers_json=$(echo "$writers" | jq -R 'split(",") | map(select(length > 0))')
    
    # Generate a UUID for the event
    local event_id=$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid)
    
    # NOTE: Remove $ prefixes from acl keys when posting via HTTP API
    local payload=$(jq -n \
        --arg eventId "$event_id" \
        --argjson readers "$readers_json" \
        --argjson writers "$writers_json" \
        '[{
            "eventId": $eventId,
            "eventType": "$metadata",
            "data": {
                "acl": {
                    "r": $readers,
                    "w": $writers,
                    "d": ["admin"],
                    "mw": ["admin"]
                }
            }
        }]')
    
    # Debug: show the payload
    echo ""
    # echo "  DEBUG Payload: $payload"
    
    local response=$(curl $CURL_OPTS -s -w "\n%{http_code}" -X POST \
        "$KURRENTDB_SCHEME://$KURRENTDB_HOST:$KURRENTDB_PORT/streams/$stream/metadata" \
        -H "Content-Type: application/vnd.eventstore.events+json" \
        -H "ES-ExpectedVersion: -2" \
        -u "$KURRENTDB_ADMIN_USERNAME:$KURRENTDB_ADMIN_PASSWORD" \
        -d "$payload")
    
    local http_code=$(echo "$response" | tail -n1)
    local response_body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" = "201" ] || [ "$http_code" = "200" ]; then
        echo -e "  ${GREEN}✓ Set${NC}"
    else
        echo -e "  ${RED}✗ Failed (HTTP $http_code)${NC}"
        echo -e "  ${RED}Response: $response_body${NC}"
    fi
}

# Function to set default ACLs
set_default_acls() {
    echo ""
    echo "Setting default stream ACLs... "
    
    local event_id=$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid)
    
    local payload=$(jq -n \
        --arg eventId "$event_id" \
        '{
            "eventId": $eventId,
            "eventType": "update-default-acl",
            "data": {
                "$userStreamAcl": {
                    "$r": "$all",
                    "$w": "$all",
                    "$d": ["admin"],
                    "$mr": ["admin"],
                    "$mw": ["admin"]
                },
                "$systemStreamAcl": {
                    "$r": ["admin"],
                    "$w": ["admin"],
                    "$d": ["admin"],
                    "$mr": ["admin"],
                    "$mw": ["admin"]
                }
            }
        }')
    
    local response=$(curl $CURL_OPTS -s -w "\n%{http_code}" -X POST \
        "$KURRENTDB_SCHEME://$KURRENTDB_HOST:$KURRENTDB_PORT/streams/\$settings" \
        -H "Content-Type: application/vnd.eventstore.events+json" \
        -H "ES-ExpectedVersion: -2" \
        -u "$KURRENTDB_ADMIN_USERNAME:$KURRENTDB_ADMIN_PASSWORD" \
        -d "[$payload]")
    
    local http_code=$(echo "$response" | tail -n1)
    local response_body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" = "201" ] || [ "$http_code" = "200" ]; then
        echo -e "${GREEN}✓ Set${NC}"
    else
        echo -e "${RED}✗ Failed (HTTP $http_code)${NC}"
        echo -e "${RED}Response: $response_body${NC}"
    fi
}

# Create Users
echo "=========================================="
echo "Creating Users"
echo "=========================================="

# Auth Service
if [ -n "$KURRENTDB_AUTH_USERNAME" ] && [ -n "$KURRENTDB_AUTH_PASSWORD" ]; then
    create_user "$KURRENTDB_AUTH_USERNAME" "Authentication Service" "$KURRENTDB_AUTH_PASSWORD" ""
fi

# Mailer Service
if [ -n "$KURRENTDB_MAILER_USERNAME" ] && [ -n "$KURRENTDB_MAILER_PASSWORD" ]; then
    create_user "$KURRENTDB_MAILER_USERNAME" "Mailer Service" "$KURRENTDB_MAILER_PASSWORD" ""
fi

# User Service
if [ -n "$KURRENTDB_USER_USERNAME" ] && [ -n "$KURRENTDB_USER_PASSWORD" ]; then
    create_user "$KURRENTDB_USER_USERNAME" "User Service" "$KURRENTDB_USER_PASSWORD" ""
fi

# Movies Service
if [ -n "$KURRENTDB_MOVIES_USERNAME" ] && [ -n "$KURRENTDB_MOVIES_PASSWORD" ]; then
    create_user "$KURRENTDB_MOVIES_USERNAME" "Movies Service" "$KURRENTDB_MOVIES_PASSWORD" ""
fi

# Set Stream ACLs
echo ""
echo "=========================================="
echo "Setting Stream ACLs"
echo "=========================================="

# Tokens stream
if [ -n "$KURRENTDB_TOKENS_STREAM" ]; then
    set_stream_acl \
        "$KURRENTDB_TOKENS_STREAM" \
        "$KURRENTDB_USER_USERNAME,$KURRENTDB_MOVIES_USERNAME" \
        "$KURRENTDB_AUTH_USERNAME"
fi

# Usernames stream
if [ -n "$KURRENTDB_USERNAMES_STREAM" ]; then
    set_stream_acl \
        "$KURRENTDB_USERNAMES_STREAM" \
        "$KURRENTDB_MOVIES_USERNAME" \
        "$KURRENTDB_AUTH_USERNAME"
fi

# Mails stream
if [ -n "$KURRENTDB_MAILS_STREAM" ]; then
    set_stream_acl \
        "$KURRENTDB_MAILS_STREAM" \
        "$KURRENTDB_MAILER_USERNAME" \
        "$KURRENTDB_AUTH_USERNAME"
fi

# Set Default ACLs
echo ""
echo "=========================================="
echo "Setting Default ACLs"
echo "=========================================="

set_default_acls

echo ""
echo "=========================================="
echo -e "${GREEN}KurrentDB Setup: Complete!${NC}"
echo "=========================================="
echo ""
echo "Configured Services:"
[ -n "$KURRENTDB_AUTH_USERNAME" ] && echo "  ✓ $KURRENTDB_AUTH_USERNAME"
[ -n "$KURRENTDB_MAILER_USERNAME" ] && echo "  ✓ $KURRENTDB_MAILER_USERNAME"
[ -n "$KURRENTDB_USER_USERNAME" ] && echo "  ✓ $KURRENTDB_USER_USERNAME"
[ -n "$KURRENTDB_MOVIES_USERNAME" ] && echo "  ✓ $KURRENTDB_MOVIES_USERNAME"
[ -n "$KURRENTDB_KURRENTDB_ADMIN_USERNAMENAME" ] && echo "  ✓ $KURRENTDB_KURRENTDB_ADMIN_USERNAMENAME"
echo ""
echo "Configured Streams:"
[ -n "$KURRENTDB_TOKENS_STREAM" ] && echo "  ✓ $KURRENTDB_TOKENS_STREAM"
[ -n "$KURRENTDB_USERNAMES_STREAM" ] && echo "  ✓ $KURRENTDB_USERNAMES_STREAM"
[ -n "$KURRENTDB_MAILS_STREAM" ] && echo "  ✓ $KURRENTDB_MAILS_STREAM"
echo ""
