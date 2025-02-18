import pytest
import os

@pytest.fixture(autouse=True)
def mock_env_vars():
    """Mock environment variables for testing"""
    os.environ["OPENAI_API_KEY"] = "test_openai_key"
    os.environ["AZURE_SPEECH_KEY"] = "test_azure_key"
    os.environ["ZONOS_API_KEY"] = "test_zonos_key"
