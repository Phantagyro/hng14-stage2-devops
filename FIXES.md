# Bug Fixes

## api/main.py

### BUG 1 — Line 6: Hardcoded Redis host
- **Problem:** `redis.Redis(host="localhost", port=6379)` — localhost does not resolve to Redis inside Docker.
- **Fix:** Replaced with `host=os.getenv("REDIS_HOST", "redis")` and `port=int(os.getenv("REDIS_PORT", 6379))`.

### BUG 2 — Line 6: Redis password not used
- **Problem:** `REDIS_PASSWORD` was defined in `api/.env` but never passed to the Redis client.
- **Fix:** Added `password=os.getenv("REDIS_PASSWORD") or None` to the Redis connection.

### BUG 3 — Line 3: `import os` unused
- **Problem:** `os` was imported but never used, confirming environment variables were never wired up.
- **Fix:** `os.getenv()` calls added throughout.

### BUG 4 — Missing `/health` endpoint
- **Problem:** No health endpoint existed, making Docker HEALTHCHECK impossible.
- **Fix:** Added `GET /health` returning `{"status": "ok"}`.

### BUG 5 — Queue key inconsistency
- **Problem:** `r.lpush("job", job_id)` used "job" as queue key but worker used different key.
- **Fix:** Changed to `r.lpush("jobs", job_id)` — updated in worker as well.

## worker/worker.py

### BUG 6 — Line 5: Hardcoded Redis host
- **Problem:** `host="localhost"` fails in Docker networking.
- **Fix:** Replaced with `host=os.getenv("REDIS_HOST", "redis")`.

### BUG 7 — Line 5: Redis password not used
- **Problem:** No password passed to Redis connection.
- **Fix:** Added `password=os.getenv("REDIS_PASSWORD") or None`.

### BUG 8 — Line 4: `import signal` unused — no graceful shutdown
- **Problem:** `signal` was imported but no handlers registered. Worker killed forcefully on SIGTERM.
- **Fix:** Implemented `handle_shutdown()` registered for SIGTERM and SIGINT with a `running` flag.

### BUG 9 — No health check mechanism
- **Problem:** No way for Docker to verify the worker is alive.
- **Fix:** Worker writes to `/tmp/worker_health` on startup and after each loop iteration.

## frontend/app.js

### BUG 10 — Line 5: Hardcoded API URL
- **Problem:** `API_URL = "http://localhost:8000"` — localhost inside frontend container points to itself.
- **Fix:** Changed to `process.env.API_URL || 'http://api:8000'`.

### BUG 11 — Hardcoded port
- **Problem:** `app.listen(3000)` — port hardcoded with no env var support.
- **Fix:** Changed to `process.env.PORT || 3000`.

## api/.env

### BUG 12 — Secrets committed to version control
- **Problem:** `api/.env` containing `REDIS_PASSWORD=supersecretpassword123` was committed to the repository.
- **Fix:** Removed from git tracking, added `.env` to `.gitignore`, created `.env.example`.

## requirements.txt (api and worker)

### BUG 13 — Unpinned dependencies
- **Problem:** No version pins, leading to non-deterministic builds.
- **Fix:** Pinned all dependencies to specific versions.
