import pytest
import asyncio
import time
from datetime import datetime, timedelta
import psutil
import os

from app.websockets.manager import ConnectionManager
from app.websockets.errors import WebSocketError, WebSocketErrorCode
from tests.websockets.mocks import MockWebSocket

pytestmark = pytest.mark.asyncio

async def test_connection_limits(manager):
    websockets = []
    
    # Get initial memory usage
    process = psutil.Process(os.getpid())
    initial_mem = process.memory_info().rss / 1024 / 1024  # MB
    
    # Test connection up to limit (using smaller sample for tests)
    test_connections = 100  # Reduced for testing
    for i in range(test_connections):
        websocket = MockWebSocket()
        client_id = f"test_client_{i}"
        connected = await manager.connect(client_id, websocket)
        assert connected, f"Failed to connect client {i}"
        websockets.append((client_id, websocket))
        
        # Verify memory usage
        if i > 0 and i % 10 == 0:
            process = psutil.Process(os.getpid())
            mem_usage = process.memory_info().rss / 1024 / 1024  # MB
            mem_per_conn = (mem_usage - initial_mem) / (i + 1)
            assert mem_per_conn < 5, f"Memory usage per connection exceeds limit: {mem_per_conn:.2f}MB"
        
        # Verify memory usage
        process = psutil.Process(os.getpid())
        mem_usage = process.memory_info().rss / 1024 / 1024  # MB
        assert mem_usage / (i + 1) < 5, f"Memory usage per connection exceeds limit: {mem_usage/(i+1):.2f}MB"
    
    # Verify connection rejection after limit
    websocket = MockWebSocket()
    connected = await manager.connect("overflow_client", websocket)
    assert not connected, "Should reject connection after limit"
    
    # Cleanup
    for client_id, _ in websockets:
        await manager.disconnect(client_id)

async def test_heartbeat(manager):
    websocket = MockWebSocket()
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
    await manager.cleanup_stale_connections()
    assert not manager.is_connected(client_id), "Connection should be closed after timeout"

async def test_reconnection(manager):
    websocket = MockWebSocket()
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

async def test_error_handling(manager):
    websocket = MockWebSocket()
    client_id = "test_client"
    
    # Test invalid state error
    await manager.connect(client_id, websocket)
    with pytest.raises(WebSocketError) as exc_info:
        await manager.connect(client_id, websocket)
    assert exc_info.value.code == WebSocketErrorCode.INVALID_STATE
    
    # Test connection error
    await manager.disconnect(client_id)
    await manager.cleanup_stale_connections()  # Ensure cleanup
    with pytest.raises(WebSocketError) as exc_info:
        await manager.send_heartbeat(client_id)
    assert exc_info.value.code == WebSocketErrorCode.CONNECTION_ERROR
    
    # Test rate limit error
    for i in range(manager.MAX_CONNECTIONS + 1):
        test_websocket = MockWebSocket()
        test_id = f"test_client_{i}"
        if i < manager.MAX_CONNECTIONS:
            assert await manager.connect(test_id, test_websocket), f"Failed to connect client {i}"
        else:
            assert not await manager.connect(test_id, test_websocket), "Should reject connection after limit"
