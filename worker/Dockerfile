FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /install /usr/local
COPY worker.py .
RUN useradd -r -u 1001 -g root appuser \
    && chown -R appuser:root /app \
    && touch /tmp/worker_health \
    && chown appuser:root /tmp/worker_health
USER appuser
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD test -f /tmp/worker_health || exit 1
CMD ["python", "worker.py"]
