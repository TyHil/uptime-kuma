#!/bin/bash
set -euo pipefail

# Configuration
THRESHOLD=80
ENV_FILE="${1:?Usage: $0 <path-to-env-file>}"

# Check for and load environment variables
if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing env file: $ENV_FILE" >&2
  exit 1
fi
source "$ENV_FILE"
if [[ -z "${MOUNT:-}" ]]; then
  echo "MOUNT not set in $ENV_FILE" >&2
  exit 1
fi
if [[ -z "${KUMA_PUSH_URL:-}" ]]; then
  echo "KUMA_PUSH_URL not set in $ENV_FILE" >&2
  exit 1
fi

USAGE=$(df --output=pcent "$MOUNT" 2>/dev/null | tail -1 | tr -dc '0-9')

if [[ -z "$USAGE" ]]; then
  echo "Could not determine disk usage for $MOUNT" >&2
  exit 1
fi

if (( USAGE >= THRESHOLD )); then
  KUMA_STATUS="down"
  KUMA_MSG="WARNING: ${MOUNT} usage at ${USAGE}%"
else
  KUMA_STATUS="up"
  KUMA_MSG="OK"
fi

curl -fsS -m 10 --retry 3 -G "$KUMA_PUSH_URL" --data-urlencode "status=${KUMA_STATUS}" --data-urlencode "msg=${KUMA_MSG}" --data-urlencode "ping=${USAGE}" > /dev/null
