export COMPOSE_FILE := "docker-compose.local.yml"

# Use bash for consistency and process substitution support if needed
set shell := ["bash", "-cu"]

# Default: show available commands
default:
    @just --list

# ---------------------------------------------------------
# Core Commands
# ---------------------------------------------------------

# build: Build all images
build *args:
    @echo "Building python image..."
    @doppler run -- docker compose build {{args}}

# up: Start all containers
up:
    @echo "Starting containers..."
    @doppler run -- docker compose up -d --remove-orphans

# down: Stop containers
down:
    @echo "Stopping containers..."
    @docker compose down

# prune: Stop and remove volumes
prune *args:
    @echo "Removing containers and volumes..."
    @docker compose down -v {{args}}

# logs: Tail logs for all services or specific ones
logs *args:
    @doppler run -- docker compose logs -f {{args}}

# manage: Run Django manage.py commands
manage +args:
    @doppler run -- docker compose run --rm django python manage.py {{args}}


## Custom Below

docs:
    @doppler run -- docker compose -f docker-compose.docs.yml up --build
    @echo "Documentation server is running at http://localhost:9000"

# backup postgres
backup-db *args:
    @doppler run -- docker compose -f docker-compose.local.yml exec postgres backup
    @echo "Database backup created."

# runs pytest inside the django container
pytest *args:
    @doppler run -- docker compose run --rm django pytest {{args}}

# check coverage
coverage:
    @doppler run -- docker compose run --rm django coverage report -m
    @doppler run -- docker compose run --rm django coverage html
    @echo "HTML coverage report generated at htmlcov/index.html"

unit-test *args:
    @doppler run -- docker compose run --rm django python manage.py test {{args}}

# ---------------------------------------------------------
# Helpers
# ---------------------------------------------------------

# ps: Show running containers
ps:
    @docker compose ps

# restart: Restart all containers without rebuilding
restart:
    @echo "Restarting containers..."
    @doppler run -- docker compose down
    @doppler run -- docker compose up -d

# rebuild: Rebuild images + recreate containers
rebuild:
    @echo "Rebuilding containers..."
    @doppler run -- docker compose down
    @doppler run -- docker compose build
    @doppler run -- docker compose up -d --remove-orphans

# shell: Open a shell inside the Django container
shell:
    @doppler run -- docker compose exec django bash

# worker-shell: Shell into celeryworker container
worker-shell:
    @doppler run -- docker compose exec celeryworker bash

# beat-shell: Shell into celerybeat
beat-shell:
    @doppler run -- docker compose exec celerybeat bash

# flower-shell: Shell into flower container (if needed)
flower-shell:
    @doppler run -- docker compose exec flower bash

# db-shell: Open psql inside postgres container
db-shell:
    @doppler run -- docker compose exec postgres psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}

# redis-shell: Open redis-cli inside redis container
redis-shell:
    @doppler run -- docker compose exec redis redis-cli
