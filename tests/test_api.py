import sys
import os
from unittest.mock import MagicMock, patch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'api'))

mock_redis = MagicMock()

with patch('redis.Redis', return_value=mock_redis):
    from main import app

from fastapi.testclient import TestClient

client = TestClient(app)


def test_create_job():
    mock_redis.lpush.return_value = 1
    mock_redis.hset.return_value = 1
    response = client.post("/jobs")
    assert response.status_code == 200
    assert "job_id" in response.json()


def test_get_job_found():
    mock_redis.hget.return_value = b"queued"
    response = client.get("/jobs/test-id-123")
    assert response.status_code == 200
    assert response.json()["status"] == "queued"


def test_get_job_not_found():
    mock_redis.hget.return_value = None
    response = client.get("/jobs/nonexistent")
    assert response.status_code == 200
    assert "error" in response.json()


def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200


def test_create_job_returns_uuid():
    mock_redis.lpush.return_value = 1
    mock_redis.hset.return_value = 1
    response = client.post("/jobs")
    job_id = response.json()["job_id"]
    assert len(job_id) == 36