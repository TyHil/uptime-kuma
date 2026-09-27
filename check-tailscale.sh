#!/bin/bash
set -euo pipefail

# Configuration
ENV_FILE=".env.tailscale"

# Check for and load environment variables
if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing env file: $ENV_FILE" >&2
  exit 1
fi
source "$ENV_FILE"
if [[ -z "${REMOTE_HOST:-}" ]]; then
  echo "REMOTE_HOST not set in $ENV_FILE" >&2
  exit 1
fi
if [[ -z "${KUMA_PUSH_URL:-}" ]]; then
  echo "KUMA_PUSH_URL not set in $ENV_FILE" >&2
  exit 1
fi

# Perform self health checks
if systemctl is-active --quiet tailscaled; then
  # Tailscale daemon is active
  TAILSCALE_IP=$(tailscale ip -4)
  if [ ! -z "$TAILSCALE_IP" ]; then
    # Tailscale IP found
    if systemctl status tailscaled | grep -q "Status.*Connected"; then
      # Tailscale shows connected status
      KUMA_STATUS="up"
      KUMA_MSG="Tailscale healthy - IP: $TAILSCALE_IP"
    else
      KUMA_STATUS="down"
      KUMA_MSG="Not showing connected status"
    fi
  else
    KUMA_STATUS="down"
    KUMA_MSG="No IP assigned"
  fi
else
  KUMA_STATUS="down"
  KUMA_MSG="Daemon not active"
fi

# Perform remote health checks
if [ "$KUMA_STATUS" = "up" ]; then
  if ! ping -c 1 -W 2 "$REMOTE_HOST" > /dev/null; then
    KUMA_STATUS="down"
    KUMA_MSG="Remote host $REMOTE_HOST unreachable"
  fi
fi

# Send status
curl -fsS -m 10 --retry 3 -G "$KUMA_PUSH_URL" --data-urlencode "status=${KUMA_STATUS}" --data-urlencode "msg=${KUMA_MSG}" > /dev/null
