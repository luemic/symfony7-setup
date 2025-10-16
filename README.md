Symfony development environment with Docker

This repository provides a lightweight Docker setup for a local Symfony development environment (PHP-FPM, Nginx, MariaDB). It also includes convenient Makefile helpers to initialize a new Symfony project in this repository.

Contents
- PHP 8.2 FPM (with intl, pdo_mysql, zip, gd, opcache) + Composer
- Nginx (serves /project/public)
- MariaDB 11 (with a persistent volume)
- Makefile commands for build/start/logs/shell/composer/init

Prerequisites
- Docker Desktop or Docker Engine
- Docker Compose v2 (command: "docker compose")
- Optional: make

Quick start
1) Build images
   make build

2) Create a new Symfony project (in the ./project subfolder)
   make init
   Note: The repository may contain other files (e.g. Docker, Makefile). The Symfony project will be installed into the ./project subfolder.

   Under the hood, this runs:
   - composer create-project symfony/skeleton into a temporary directory
   - composer require symfony/property-access, symfony/http-client and symfony/webapp-pack --dev (in the temporary directory)
   - copy the generated project files into the ./project subfolder

3) Start the containers
   make up

4) Open the app
   http://localhost:8080

Useful commands
- make logs        → Tail container logs
- make sh          → Open a shell in the PHP container
- make composer ARGS="require symfony/uid" → Run Composer inside the container
- make cache-clear → Clear the Symfony cache
- make down        → Stop and remove containers

Database
- Container name: symfony-db (MariaDB 11)
- Default creds: user=app, password=app, database=app
- Host from other containers: symfony-db, port 3306
- Host from your machine: 127.0.0.1:3306

Symfony .env configuration
After the Symfony project has been created, adjust the database connection in .env (or .env.local):

- Inside the container (e.g. when running bin/console from the PHP container):
  DATABASE_URL="mysql://app:app@symfony-db:3306/app?serverVersion=11&charset=utf8mb4"

- From the host (e.g. local IDE DB tool):
  mysql://app:app@127.0.0.1:3306/app

Project structure (key files)
- docker-compose.yml        → defines services: php, nginx, db
- docker/php/Dockerfile     → PHP 8.2 FPM + extensions + Composer
- docker/php/php.ini        → Development-friendly PHP settings
- docker/nginx/default.conf → Nginx config (root: /project/public)
- Makefile                  → Handy commands
- scripts/init.sh           → Alternative to Makefile: project initialization

Alternative without make
- docker compose build
- docker compose up -d
- ./scripts/init.sh

Troubleshooting
- Port 8080 already in use? Change the port in docker-compose.yml under nginx: ports.
- Permission issues (var/): make perms
- Composer/network issues: Ensure the host has internet access and Docker allows outbound traffic.
- Error during importmap:require regarding AssetMapper/HttpClient: "You cannot use the AssetMapper integration since the HttpClient component is not enabled". Fix by running `make composer ARGS="require symfony/http-client"` (enables framework.http_client), then retry.
- Node/asset builds: This setup focuses on PHP/Nginx/DB. For asset pipelines (Encore/Vite), use Node locally or add a Node container as needed.

License
This setup is a starting point and can be adapted freely.
