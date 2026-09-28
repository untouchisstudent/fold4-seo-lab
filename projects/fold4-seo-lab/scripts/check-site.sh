#!/data/data/com.termux/files/usr/bin/bash

URL="$1"

if [ -z "$URL" ]; then
  echo "Usage: ./check-site.sh https://example.com"
  exit 1
fi

case "$URL" in
  http://*|https://*)
    ;;
  *)
    echo "Error: URL harus diawali http:// atau https://"
    exit 1
    ;;
esac

echo "======================================"
echo "SITE CHECK"
echo "URL: $URL"
echo "======================================"

echo
echo "[HTTP]"
curl -L -sS -o /dev/null \
  -w "Status       : %{http_code}
Redirects    : %{num_redirects}
Final URL    : %{url_effective}
Response time: %{time_total}s
" \
  --max-time 20 "$URL"

echo
echo "[TITLE]"
curl -L -sS --max-time 20 "$URL" \
  | tr '
' ' ' \
  | grep -ioE '<title[^>]*>[^<]*</title>' \
  | head -n 1

echo
echo "[META DESCRIPTION]"
curl -L -sS --max-time 20 "$URL" \
  | tr '
' ' ' \
  | grep -ioE '<meta[^>]+name=["'"'"']description["'"'"'][^>]*>' \
  | head -n 1

echo
echo "[H1]"
H1_COUNT=$(curl -L -sS --max-time 20 "$URL" \
  | grep -ioE '<h1[^>]*>[^<]*</h1>' \
  | wc -l \
  | tr -d ' ')

echo "Jumlah H1: $H1_COUNT"

echo
echo "[CANONICAL]"
CANONICAL=$(curl -L -sS --max-time 20 "$URL" \
  | tr '
' ' ' \
  | grep -ioE '<link[^>]+rel=["'"'"']canonical["'"'"'][^>]*>' \
  | head -n 1)

if [ -n "$CANONICAL" ]; then
  echo "$CANONICAL"
else
  echo "Canonical tidak ditemukan"
fi

echo
echo "[ANCHOR LINKS]"
ANCHOR_LINKS=$(curl -L -sS --max-time 20 "$URL" \
  | tr '
' ' ' \
  | grep -oE '<a[^>]+href=["'"'"'][^"'"'"']+["'"'"']' \
  | wc -l \
  | tr -d ' ')

echo "Jumlah link anchor: $ANCHOR_LINKS"

echo
echo "[STRUCTURED DATA]"
SCHEMA_COUNT=$(curl -L -sS --max-time 20 "$URL" \
  | grep -io 'application/ld+json' \
  | wc -l \
  | tr -d ' ')

echo "Jumlah JSON-LD: $SCHEMA_COUNT"

echo
echo "[ROBOTS]"
ROBOTS_URL="${URL%/}/robots.txt"
ROBOTS_STATUS=$(curl -L -sS -o /dev/null -w "%{http_code}" \
  --max-time 20 "$ROBOTS_URL")

echo "URL    : $ROBOTS_URL"
echo "Status : $ROBOTS_STATUS"

echo
echo "[SITEMAP]"
SITEMAP_URL="${URL%/}/sitemap.xml"
SITEMAP_STATUS=$(curl -L -sS -o /dev/null -w "%{http_code}" \
  --max-time 20 "$SITEMAP_URL")

echo "URL    : $SITEMAP_URL"
echo "Status : $SITEMAP_STATUS"

echo
echo "[DONE]"
