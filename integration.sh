#!/bin/bash
set -e

# Bring stack up
docker compose -f docker-compose.yml up -d --build

# Wait for healthy
timeout 120 bash -c '
  until \
    docker compose ps | grep redis | grep -q "healthy" && \
    docker compose ps | grep api | grep -q "healthy" && \
    docker compose ps | grep frontend | grep -q "healthy"; do
    sleep 5
  done
'

# Submit job
JOB_ID=$(curl -s -X POST http://localhost:3000/submit | \
  python3 -c "import sys,json; print(json.load(sys.stdin)['job_id'])")
echo "Submitted: $JOB_ID"

# Poll
timeout 60 bash -c '
  while true; do
    STATUS=$(curl -s http://localhost:3000/status/'"$JOB_ID"' | \
      python3 -c "import sys,json; print(json.load(sys.stdin)[\"status\"])")
    echo "Status: $STATUS"
    [ "$STATUS" = "completed" ] && break
    sleep 2
  done
'

# Assert
STATUS=$(curl -s http://localhost:3000/status/$JOB_ID | \
  python3 -c "import sys,json; print(json.load(sys.stdin)['status'])")
if [ "$STATUS" != "completed" ]; then
  echo "FAILED: got $STATUS"
  exit 1
fi
echo "PASSED"