#!/usr/bin/env bash
set -e

# Start Tailscale if auth key is provided
if [ -n "$TAILSCALE_AUTH_KEY" ]; then
  mkdir -p /data/tailscale /var/run/tailscale

  echo "[tailscale] starting daemon (userspace networking)..."
  tailscaled \
    --state=/data/tailscale/tailscaled.state \
    --socket=/var/run/tailscale/tailscaled.sock \
    --tun=userspace-networking &

  # Wait for the daemon socket to appear
  for i in $(seq 1 10); do
    [ -S /var/run/tailscale/tailscaled.sock ] && break
    sleep 1
  done

  echo "[tailscale] connecting..."
  tailscale --socket=/var/run/tailscale/tailscaled.sock up \
    --authkey="${TAILSCALE_AUTH_KEY}" \
    --hostname="${TAILSCALE_HOSTNAME:-railway-openclaw}"

  echo "[tailscale] connected as $(tailscale --socket=/var/run/tailscale/tailscaled.sock ip -4)"
fi

# Start the main application
exec node src/server.js
