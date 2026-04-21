import redis
import time
import os
import signal

HEALTH_FILE = "/tmp/worker_health"

r = redis.Redis(
    host=os.getenv("REDIS_HOST", "redis"),
    port=int(os.getenv("REDIS_PORT", 6379)),
    password=os.getenv("REDIS_PASSWORD") or None,
)

running = True


def handle_shutdown(signum, frame):
    global running
    print("Shutting down gracefully...")
    running = False


signal.signal(signal.SIGTERM, handle_shutdown)
signal.signal(signal.SIGINT, handle_shutdown)


def update_health():
    with open(HEALTH_FILE, "w") as f:
        f.write("ok")


def process_job(job_id):
    print(f"Processing job {job_id}")
    time.sleep(2)
    r.hset(f"job:{job_id}", "status", "completed")
    print(f"Done: {job_id}")


update_health()

while running:
    job = r.brpop("jobs", timeout=5)
    if job:
        _, job_id = job
        process_job(job_id.decode())
    update_health()

print("Worker stopped")
