import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

from app.websockets.middleware import WebSocketMiddleware
from app.websockets.manager import ConnectionManager

@pytest.fixture
def app():
    app = FastAPI()
    app.add_middleware(WebSocketMiddleware)
    return app

@pytest.fixture
def test_client(app):
    return TestClient(app)

@pytest.fixture
def manager():
    return ConnectionManager()
