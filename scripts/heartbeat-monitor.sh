#!/bin/bash

# Usage: ./heartbeat-monitor.sh <URL>
URL="$1"
DURATION=120
INTERVAL=1
ENDPOINTS=("/health" "/ready" "/startup")

# Validate input
if [ -z "$URL" ]; then
    echo "Usage: $0 <URL>"
    exit 1
fi

echo "Starting health check loop for $DURATION seconds..."
echo "--------------------------------------------------------------------------"
printf "| %-15s | %-10s | %-50s |\n" "Path URL" "Response" "Body"
echo "--------------------------------------------------------------------------"

CURL_CMD=$(which curl)
CAT_CMD=$(which cat)
SLEEP_CMD=$(which sleep)

for ((i=1; i<=$DURATION; i++)); do
    for PATH in "${ENDPOINTS[@]}"; do
        RESPONSE=$($CURL_CMD -s -o response.txt -w "%{http_code}" "$URL$PATH")
        BODY=$($CAT_CMD response.txt)

        printf "| %-15s | %-10s | %-50s |\n" "$PATH" "$RESPONSE" "$BODY"
    done
    echo "--------------------------------------------------------------------------"

    $SLEEP_CMD $INTERVAL
done

echo "--------------------------------------------------------------------------"

# echo "Starting HTTP request loop for $DURATION seconds..."
# echo "Target URL: $URL"
# echo "-------------------------------------------"
# 
# for ((i=1; i<=$DURATION; i++)); do
#     RESPONSE=$(curl -s -o response.txt -w "%{http_code}" "$URL")
#     BODY=$(cat response.txt)
#     
#     echo "[Request #$i] URL: $URL"
#     echo "HTTP Response: $RESPONSE"
#     echo "Body Response:"
#     echo "$BODY"
#     echo "-------------------------------------------"
#     
#     sleep $INTERVAL
# done

echo "Loop completed."

