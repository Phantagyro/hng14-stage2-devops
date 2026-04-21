#!/bin/bash
set -eo pipefail

TIMEOUT=60
SERVICE=${1:?"Usage: $0 <service-name>"}
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.test.yml}"

echo "Starting rolling update for: $SERVICE"

OLD_CONTAINER=$(docker compose -f "$COMPOSE_FILE" ps -q "$SERVICE" 2>/dev/null | head -1)
echo "Old container: ${OLD_CONTAINER:-none}"

echo "Starting new container..."
docker compose -f "$COMPOSE_FILE" up -d --no-deps --force-recreate "$SERVICE"

NEW_CONTAINER=$(docker compose -f "$COMPOSE_FILE" ps -q "$SERVICE" 2>/dev/null | head -1)
echo "New container: $NEW_CONTAINER"

echo "Waiting for health check (timeout: ${TIMEOUT}s)..."
ELAPSED=0
HEALTHY=false

while [ $ELAPSED -lt $TIMEOUT ]; do
    HEALTH=$(docker inspect --format='{{.State.Health.Status}}' "$NEW_CONTAINER" 2>/dev/null || echo "unknown")
    echo "  [${ELAPSED}s] $SERVICE health: $HEALTH"

    if [ "$HEALTH" = "healthy" ]; then
        HEALTHY=true
        break
    fi

    if [ "$HEALTH" = "unhealthy" ]; then
        echo "Container is unhealthy. Aborting."
        break
    fi

    sleep 2
    ELAPSED=$((ELAPSED + 2))
done

if [ "$HEALTHY" = "true" ]; then
    echo "Rolling update successful!"
    if [ -n "$OLD_CONTAINER" ] && [ "$OLD_CONTAINER" != "$NEW_CONTAINER" ]; then
        docker stop "$OLD_CONTAINER" 2>/dev/null || true
        docker rm "$OLD_CONTAINER" 2>/dev/null || true
    fi
    exit 0
else
    echo "ERROR: Health check failed. Keeping old container."
    docker compose -f "$COMPOSE_FILE" stop "$SERVICE" 2>/dev/null || true
    if [ -n "$OLD_CONTAINER" ]; then
        docker start "$OLD_CONTAINER" 2>/dev/null || true
    fi
    exit 1
fi
