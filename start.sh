#!/usr/bin/env bash
set -e

# Start Tailscale if auth key is provided
if [ -n "$TAILSCALE_AUTH_KEY" ]; then
  echo "[tailscale] starting daemon..."
  tailscaled --state=/data/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock &
  sleep 2

  echo "[tailscale] connecting..."
  tailscale up --authkey="${TAILSCALE_AUTH_KEY}" --hostname="${TAILSCALE_HOSTNAME:-railway-openclaw}"
  echo "[tailscale] connected as $(tailscale ip -4)"
fi

# Start the main application
exec node src/server.js
