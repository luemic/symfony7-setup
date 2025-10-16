#!/usr/bin/env bash
set -euo pipefail

DC="docker compose"

# Abort if already initialized
if [ -f project/public/index.php ]; then
  echo "Symfony already initialized (project/public/index.php exists). Aborting." >&2
  exit 1
fi

# Create project in temporary directory and copy into ./project
$DC run --rm -w /var/www/html php bash -lc '
set -euo pipefail
mkdir -p project
SYM_TMP=$(mktemp -d -p /tmp symfony-init-XXXXXX) || { echo "Failed to create temp dir"; exit 1; }
[ -d "$SYM_TMP" ] || { echo "Temp dir not found: $SYM_TMP"; exit 1; }
composer create-project symfony/skeleton "$SYM_TMP"
cd "$SYM_TMP"
composer require symfony/property-access
composer require symfony/http-client
composer require symfony/webapp-pack --dev
[ -d "$SYM_TMP" ] || { echo "Temp dir missing before copy: $SYM_TMP"; exit 1; }
cp -a "$SYM_TMP"/. /var/www/html/project/
echo "Symfony files copied into project/ directory."
'

echo "Symfony project created in ./project. Start stack with: make up (then open http://localhost:8080)"
