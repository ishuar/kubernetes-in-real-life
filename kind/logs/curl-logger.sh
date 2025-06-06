#!/bin/bash

# ------------------------------------------
# Script: curl-loop-logger.sh
# Description: Loops every 0.5s for N seconds, curls a URL, logs & displays output
# Usage: ./curl-loop-logger.sh <duration_in_seconds> [url]
# Default URL: http://podinfo.eu-01-a.internal.scayle-payments.com/
# ------------------------------------------

set -euo pipefail

# ✅ Constants
DEFAULT_URL="http://podinfo-latest.eu-01-a.internal.scayle-payments.com/"

# ✅ Parse arguments
if [ $# -lt 1 ]; then
  echo "Usage: $0 <duration_in_seconds> [url]"
  exit 1
fi

DURATION="$1"
URL="${2:-$DEFAULT_URL}" # Use provided URL or fallback to default

# ✅ Validate that curl exists
command -v curl >/dev/null 2>&1 || {
  echo >&2 "❌ Error: 'curl' is required but not installed."
  exit 1
}

# ✅ Log file
LOG_FILE="curl_log_$(date '+%Y%m%d_%H%M%S').log"

# ✅ Time setup
START_TIME=$(date +%s)
END_TIME=$((START_TIME + DURATION))

# ✅ Start loop
echo "▶️ Starting curl loop for $DURATION seconds"
echo "📍 Target URL: $URL"
echo "📜 Logging to: $LOG_FILE"
echo "--------------------------------------------------" | tee -a "$LOG_FILE"

while [ "$(date +%s)" -lt "$END_TIME" ]; do
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$TIMESTAMP] Requesting $URL" | tee -a "$LOG_FILE"

  RESPONSE=$(curl -s --max-time 2 "$URL" || echo "ERROR: Curl failed at $TIMESTAMP")
  echo "$RESPONSE" | tee -a "$LOG_FILE"

  echo "--------------------------------------------------" | tee -a "$LOG_FILE"
  sleep 0.5
done

echo "✅ Done. Full log saved to: $LOG_FILE"
