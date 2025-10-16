PROJECT_NAME?=symfony
DOCKER_COMPOSE?=docker compose

.PHONY: help build up down restart logs ps sh php-shell composer init new cache-clear perms db

help:
	@echo "Targets:"
	@echo "  build        Build docker images"
	@echo "  up           Start containers in background"
	@echo "  down         Stop and remove containers"
	@echo "  restart      Restart containers"
	@echo "  logs         Tail logs"
	@echo "  ps           Show container status"
	@echo "  sh           Shell into PHP container"
	@echo "  php-shell    Shell into PHP container (alias)"
	@echo "  composer     Run composer (e.g., make composer ARGS=install)"
	@echo "  init         Create new Symfony app in current directory"
	@echo "  new          Alias of init"
	@echo "  cache-clear  Clear Symfony cache"
	@echo "  perms        Fix filesystem permissions (var/)"
	@echo "  db           Show DB connection info"

build:
	$(DOCKER_COMPOSE) build

up:
	$(DOCKER_COMPOSE) up -d

restart:
	$(DOCKER_COMPOSE) restart

logs:
	$(DOCKER_COMPOSE) logs -f --tail=150

ps:
	$(DOCKER_COMPOSE) ps

down:
	$(DOCKER_COMPOSE) down

sh php-shell:
	$(DOCKER_COMPOSE) exec php bash || $(DOCKER_COMPOSE) run --rm php bash

composer:
	$(DOCKER_COMPOSE) run --rm -w /var/www/html/project php composer $(ARGS)

init new:
	@echo "Initializing Symfony application into ./project (non-empty repo supported)..."
	$(DOCKER_COMPOSE) run --rm -w /var/www/html php bash -lc '\
set -euo pipefail; \
if [ -f project/public/index.php ]; then echo "Symfony already initialized (project/public/index.php exists). Aborting."; exit 1; fi; \
mkdir -p project; \
SYM_TMP=$$(mktemp -d -p /tmp symfony-init-XXXXXX) || { echo "Failed to create temp dir"; exit 1; }; \
[ -d "$$SYM_TMP" ] || { echo "Temp dir not found: $$SYM_TMP"; exit 1; }; \
composer create-project symfony/skeleton "$$SYM_TMP"; \
cd "$$SYM_TMP"; composer require symfony/property-access; composer require symfony/http-client; composer require symfony/webapp-pack --dev; \
[ -d "$$SYM_TMP" ] || { echo "Temp dir missing before copy: $$SYM_TMP"; exit 1; }; \
cp -a "$$SYM_TMP"/. /var/www/html/project/; \
echo "Symfony files copied into project/ directory."'
	@echo "Done. You can now run: make up and open http://localhost:8080"

cache-clear:
	$(DOCKER_COMPOSE) exec php bash -lc 'php bin/console cache:clear'

perms:
	$(DOCKER_COMPOSE) exec php bash -lc 'mkdir -p var && chmod -R 777 var'

db:
	@echo "Database connection (Docker):"
	@echo "  DSN: mysql://app:app@127.0.0.1:3306/app"
