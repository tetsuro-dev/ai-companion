import pytest
import os
from unittest.mock import patch
from .mocks import MockSpeechService, MockOpenAI


@pytest.fixture(autouse=True)
def mock_env_vars():
    """Mock environment variables for testing"""
    os.environ["OPENAI_API_KEY"] = "test_openai_key"
    os.environ["AZURE_SPEECH_KEY"] = "test_azure_key"
    os.environ["ZONOS_API_KEY"] = "test_zonos_key"


@pytest.fixture(autouse=True)
def mock_services():
    """Mock external services to prevent API calls"""
    with patch("app.routes.speech.routes.SpeechService", return_value=MockSpeechService()), \
         patch("app.services.chat_service.openai", MockOpenAI()):
        yield
