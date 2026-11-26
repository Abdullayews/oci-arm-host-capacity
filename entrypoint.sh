#!/bin/sh
set -e

# Base64 formatındakı private key-i dekod edib /tmp/key.pem faylına yazırıq
echo "$OCI_PRIVATE_KEY_B64" | base64 -d > /tmp/key.pem
chmod 600 /tmp/key.pem
export OCI_PRIVATE_KEY_FILENAME=/tmp/key.pem

# Render-in portunu açıq saxlamaq üçün mini HTTP server (ping üçün)
mkdir -p /tmp/www
echo "OK" > /tmp/www/index.html
php -S 0.0.0.0:${PORT:-10000} -t /tmp/www >/dev/null 2>&1 &

# Hər 60 saniyədən bir OCI sorğusu göndəririk
while true; do
  echo "[$(date -u)] Yoxlanılır..."
  php /app/index.php || true
  sleep 60
done
