#!/bin/bash
set -e

TIMEOUT=${INTEGRATION_TIMEOUT:-60}
BASE_URL=${BASE_URL:-http://localhost:3000}

echo "Submitting job..."
JOB_RESPONSE=$(curl -sf -X POST "$BASE_URL/submit")
echo "Response: $JOB_RESPONSE"
JOB_ID=$(echo "$JOB_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['job_id'])")
echo "Job ID: $JOB_ID"

ELAPSED=0
while [ $ELAPSED -lt $TIMEOUT ]; do
  STATUS=$(curl -sf "$BASE_URL/status/$JOB_ID" | python3 -c "import sys,json; print(json.load(sys.stdin).get('status','unknown'))")
  echo "[${ELAPSED}s] status=$STATUS"
  if [ "$STATUS" = "completed" ]; then
    echo "Integration test passed!"
    exit 0
  fi
  sleep 2
  ELAPSED=$((ELAPSED + 2))
done

echo "Integration test failed - job did not complete within ${TIMEOUT}s."
exit 1
