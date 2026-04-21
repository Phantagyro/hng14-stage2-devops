import pytest
from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient


@pytest.fixture(autouse=True)
def mock_redis():
    with patch("main.r") as mock_r:
        yield mock_r


with patch("redis.Redis"):
    from main import app

client = TestClient(app)


def test_health_endpoint():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_create_job(mock_redis):
    mock_redis.lpush.return_value = 1
    mock_redis.hset.return_value = 1

    response = client.post("/jobs")
    assert response.status_code == 200
    data = response.json()
    assert "job_id" in data
    mock_redis.lpush.assert_called_once()
    mock_redis.hset.assert_called_once()


def test_create_job_returns_valid_uuid(mock_redis):
    import uuid
    mock_redis.lpush.return_value = 1
    mock_redis.hset.return_value = 1

    response = client.post("/jobs")
    data = response.json()
    uuid.UUID(data["job_id"])


def test_get_job_found(mock_redis):
    mock_redis.hget.return_value = b"queued"

    response = client.get("/jobs/test-job-id")
    assert response.status_code == 200
    data = response.json()
    assert data["job_id"] == "test-job-id"
    assert data["status"] == "queued"


def test_get_job_not_found(mock_redis):
    mock_redis.hget.return_value = None

    response = client.get("/jobs/nonexistent-id")
    assert response.status_code == 200
    assert "error" in response.json()
