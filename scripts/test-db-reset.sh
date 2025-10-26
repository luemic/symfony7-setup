#!/bin/sh
set -e
# Reset and seed the test database with fixtures
# Use MySQL root to (re)create the test database because the app user lacks CREATE/DROP privileges.
# Docker-compose sets root password to 'root' and DB host to 'symfony-db'.
DB_HOST="symfony-db"
DB_ROOT_USER="root"
DB_ROOT_PASS="root"
DB_NAME="app_test"

mysql -h"$DB_HOST" -u"$DB_ROOT_USER" -p"$DB_ROOT_PASS" -e "
  DROP DATABASE IF EXISTS \`$DB_NAME\`;
  CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
  GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO 'app'@'%';
  FLUSH PRIVILEGES;
"

# Run migrations and fixtures in test environment (Doctrine uses app_test via dbname_suffix)
APP_ENV=test php /var/www/html/project/bin/console doctrine:migrations:migrate -n
APP_ENV=test php /var/www/html/project/bin/console doctrine:fixtures:load -n

echo "Test database reset and fixtures loaded."