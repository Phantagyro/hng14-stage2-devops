FROM python:3.11-alpine AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.11-alpine
WORKDIR /app
COPY --from=builder /install /usr/local
COPY worker.py .
RUN addgroup -S appgroup && adduser -S -u 1001 -G appgroup appuser \
    && chown -R appuser:appgroup /app \
    && touch /tmp/worker_health \
    && chown appuser:appgroup /tmp/worker_health
USER appuser
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD test -f /tmp/worker_health || exit 1
CMD ["python", "worker.py"]
