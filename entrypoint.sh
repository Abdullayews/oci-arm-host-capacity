#!/bin/sh
set -e

# OCI private key: base64 env -> file with sane permissions
echo "$OCI_PRIVATE_KEY_B64" | base64 -d > /tmp/key.pem
chmod 600 /tmp/key.pem
export OCI_PRIVATE_KEY_FILENAME=/tmp/key.pem

PORT="${PORT:-10000}"
SELF_URL="${RENDER_EXTERNAL_URL:-}"

# Keep-alive web server: /health endpoint for Render + humans.
php -S 0.0.0.0:"$PORT" /app/router.php >/dev/null 2>&1 &
PHP_SERVER_PID=$!

last_check=0

log() { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] $*"; }

shutdown() {
  log "SIGTERM received, stopping"
  kill "$PHP_SERVER_PID" 2>/dev/null || true
  exit 0
}
trap shutdown TERM INT

# An inbound request through the public URL resets Render's 15-minute
# spin-down timer; the self-ping via RENDER_EXTERNAL_URL goes through
# Render's edge, so it counts as inbound traffic.
heartbeat() {
  if [ -n "$SELF_URL" ]; then
    curl -fsS -o /dev/null --max-time 20 "$SELF_URL/health" \
      && log "heartbeat ok" \
      || log "heartbeat FAILED"
  fi
  sleep 55
}

log "started: web server on :$PORT, OCI check every 60 s, self-ping ${SELF_URL:-disabled}"

while true; do
  heartbeat

  now=$(date +%s)
  if [ $((now - last_check)) -ge 60 ]; then
    last_check=$now
    log "OCI check running"
    php /app/index.php || log "OCI check failed (non-fatal, retrying next tick)"
  fi
done
