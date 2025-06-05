#!/bin/bash

# Usage: ./heartbeat-monitor.sh <URL>
URL="$1"
DURATION=30
INTERVAL=1

# Validate input
if [ -z "$URL" ]; then
    echo "Usage: $0 <URL>"
    exit 1
fi

echo "Starting HTTP request loop for $DURATION seconds..."
echo "Target URL: $URL"
echo "-------------------------------------------"

for ((i=1; i<=$DURATION; i++)); do
    RESPONSE=$(curl -s -o response.txt -w "%{http_code}" "$URL")
    BODY=$(cat response.txt)
    
    echo "[Request #$i] URL: $URL"
    echo "HTTP Response: $RESPONSE"
    echo "Body Response:"
    echo "$BODY"
    echo "-------------------------------------------"
    
    sleep $INTERVAL
done

echo "Loop completed."

