# Fixes

## frontend/app.js
- **Line 4** — `API_URL` hardcoded to `http://localhost:8000`. Fails inside Docker because localhost refers to the container itself. Fixed to use `process.env.API_URL`.

## api/main.py
- **Line 7** — Redis client hardcoded to `host="localhost"`. Fails inside Docker. Fixed to use `os.getenv("REDIS_HOST", "redis")`.
- **Line 7** — Redis password from `.env` never passed to Redis client. Fixed to use `os.getenv("REDIS_PASSWORD")`.

## worker/worker.py
- **Line 5** — Redis client hardcoded to `host="localhost"`. Fails inside Docker. Fixed to use `os.getenv("REDIS_HOST", "redis")`.
- **Line 4** — `signal` imported but never used. Causes flake8 failure. Fixed by implementing SIGTERM handler for graceful shutdown.
- **Line 10** — Infinite loop with no graceful exit. Docker stop would SIGKILL after timeout. Fixed by adding signal handler.

## api/.env
- Credentials file committed to repository. Fixed by adding `api/.env` to `.gitignore` and creating `.env.example` with placeholder values.