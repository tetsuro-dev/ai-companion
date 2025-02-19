import pytest
import asyncio
import time
from datetime import datetime, timedelta
import psutil
import os
from fastapi.testclient import TestClient

from app.websockets.manager import ConnectionManager
from app.websockets.errors import WebSocketError, WebSocketErrorCode

@pytest.mark.asyncio
async def test_connection_limits():
    manager = ConnectionManager()
    websockets = []
    
    # Test connection up to limit
    for i in range(5000):
        websocket = TestClient(app).websocket_connect("/api/speech/synthesize")
        client_id = f"test_client_{i}"
        connected = await manager.connect(client_id, websocket)
        assert connected, f"Failed to connect client {i}"
        websockets.append((client_id, websocket))
        
        # Verify memory usage
        process = psutil.Process(os.getpid())
        mem_usage = process.memory_info().rss / 1024 / 1024  # MB
        assert mem_usage / (i + 1) < 5, f"Memory usage per connection exceeds limit: {mem_usage/(i+1):.2f}MB"
    
    # Verify connection rejection after limit
    websocket = TestClient(app).websocket_connect("/api/speech/synthesize")
    connected = await manager.connect("overflow_client", websocket)
    assert not connected, "Should reject connection after limit"
    
    # Cleanup
    for client_id, _ in websockets:
        await manager.disconnect(client_id)

@pytest.mark.asyncio
async def test_heartbeat():
    manager = ConnectionManager()
    websocket = TestClient(app).websocket_connect("/api/speech/synthesize")
    client_id = "test_client"
    
    # Test successful heartbeat
    await manager.connect(client_id, websocket)
    start_time = time.time()
    success = await manager.send_heartbeat(client_id)
    latency = time.time() - start_time
    assert success, "Heartbeat should succeed"
    assert latency < 0.1, f"Heartbeat latency {latency:.3f}s exceeds 100ms threshold"
    
    # Test heartbeat timeout
    manager.last_heartbeat[client_id] = datetime.now() - timedelta(seconds=65)
    await asyncio.sleep(1)
    assert not manager.is_connected(client_id), "Connection should be closed after timeout"

@pytest.mark.asyncio
async def test_reconnection():
    manager = ConnectionManager()
    websocket = TestClient(app).websocket_connect("/api/speech/synthesize")
    client_id = "test_client"
    
    # Test reconnection attempts
    await manager.connect(client_id, websocket)
    for attempt in range(5):
        await manager.disconnect(client_id)
        start_time = time.time()
        connected = await manager.connect(client_id, websocket)
        latency = time.time() - start_time
        assert connected, f"Reconnection attempt {attempt} failed"
        assert latency < 0.2, f"Reconnection latency {latency:.3f}s exceeds 200ms threshold"

@pytest.mark.asyncio
async def test_error_handling():
    manager = ConnectionManager()
    websocket = TestClient(app).websocket_connect("/api/speech/synthesize")
    client_id = "test_client"
    
    # Test invalid state error
    await manager.connect(client_id, websocket)
    with pytest.raises(WebSocketError) as exc_info:
        await manager.connect(client_id, websocket)
    assert exc_info.value.code == WebSocketErrorCode.INVALID_STATE
    
    # Test connection error
    await manager.disconnect(client_id)
    with pytest.raises(WebSocketError) as exc_info:
        await manager.send_heartbeat(client_id)
    assert exc_info.value.code == WebSocketErrorCode.CONNECTION_ERROR
