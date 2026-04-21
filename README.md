# HNG Stage 2 — Containerized Microservices

A job processing system with a frontend, API, worker, and Redis queue — fully containerized with Docker and a complete CI/CD pipeline.

## Prerequisites

- Docker >= 24.0
- Docker Compose >= 2.0
- Git

## Quick Start

1. Clone the repo
git clone https://github.com/Phantagyro/hng14-stage2-devops
cd hng14-stage2-devops

2. Create your .env file
cp .env.example .env
Edit .env and set a strong REDIS_PASSWORD

3. Bring the stack up
docker compose up -d

4. Check all services are healthy
docker compose ps

## Services

| Service  | Port | Description                        |
|----------|------|------------------------------------|
| frontend | 3000 | Job submission dashboard           |
| api      | 8000 | FastAPI job management (internal)  |
| worker   | —    | Job processor (internal)           |
| redis    | —    | Queue and state store (internal)   |

## Endpoints

- POST /submit — Submit a new job
- GET /status/:id — Check job status

## Successful Startup

All four services should show healthy:
redis      Up (healthy)
api        Up (healthy)
worker     Up (healthy)
frontend   Up (healthy)

## CI/CD Pipeline

6 stages in strict order:
1. lint — flake8, eslint, hadolint
2. test — pytest with mocked Redis, coverage report artifact
3. build — builds all 3 images, tags with git SHA + latest
4. security-scan — Trivy scans, fails on CRITICAL, uploads SARIF
5. integration-test — full stack up, job submitted and polled
6. deploy — rolling update on push to main (60s timeout)

## Environment Variables

See .env.example for all required variables.
