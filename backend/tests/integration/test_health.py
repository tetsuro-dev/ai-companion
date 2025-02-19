from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_health_endpoint() -> None:
    """Test the health endpoint returns correct structure."""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert "status" in data
    assert "services" in data
    assert "timestamp" in data
    assert isinstance(data["services"], list)
    assert len(data["services"]) == 2  # OpenAI and Azure Speech

    # Verify service details
    services = {service["service"]: service for service in data["services"]}
    assert "openai" in services
    assert "azure_speech" in services
    for service in services.values():
        assert "status" in service
        assert service["status"] in ["healthy", "unhealthy"]
        if service["status"] == "unhealthy":
            assert "error" in service
