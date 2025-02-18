import pytest
import os
from unittest.mock import patch
from .mocks import MockSpeechService, MockOpenAI


@pytest.fixture(autouse=True)
def mock_env_vars(monkeypatch):
    """Mock environment variables for testing"""
    monkeypatch.setenv("OPENAI_API_KEY", "test_openai_key")
    monkeypatch.setenv("AZURE_SPEECH_KEY", "test_azure_key")
    monkeypatch.setenv("ZONOS_API_KEY", "test_zonos_key")


@pytest.fixture(autouse=True)
def mock_services():
    """Mock external services to prevent API calls"""
    with patch("app.routes.speech.routes.SpeechService", return_value=MockSpeechService()), \
         patch("app.services.chat_service.openai", MockOpenAI()):
        yield
