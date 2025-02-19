from fastapi import WebSocket
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.types import ASGIApp
import time
import logging
import asyncio
from typing import Optional, Dict
from .errors import WebSocketError, WebSocketErrorCode

logger = logging.getLogger(__name__)

class WebSocketMetrics:
    def __init__(self):
        self.operation_times: Dict[str, float] = {}
        self.connection_count: int = 0
        self.error_count: int = 0
        
    def record_operation_time(self, operation_id: str, duration: float):
        self.operation_times[operation_id] = duration
        if duration > 0.1:  # 100ms threshold
            logger.warning(f"WebSocket operation {operation_id} exceeded latency threshold: {duration:.3f}s")

class WebSocketMiddleware(BaseHTTPMiddleware):
    def __init__(self, app: ASGIApp):
        super().__init__(app)
        self.metrics = WebSocketMetrics()
        
    async def dispatch(self, request, call_next):
        if "websocket" not in request.scope["type"]:
            return await call_next(request)
            
        operation_id = f"{request.scope['client'][0]}:{request.scope['client'][1]}"
        start_time = time.time()
        
        try:
            # Track concurrent connections
            self.metrics.connection_count += 1
            if self.metrics.connection_count > 5000:  # Maximum connections
                logger.error(f"Connection limit exceeded: {self.metrics.connection_count}")
                raise WebSocketError(
                    WebSocketErrorCode.RATE_LIMIT,
                    "接続数が制限を超えました。しばらく待ってから再接続してください。"
                )
                
            # Process the request
            response = await call_next(request)
            
            # Record metrics
            process_time = time.time() - start_time
            self.metrics.record_operation_time(operation_id, process_time)
            
            return response
            
        except Exception as e:
            self.metrics.error_count += 1
            process_time = time.time() - start_time
            logger.error(
                f"WebSocket error in operation {operation_id}: {str(e)}, "
                f"duration: {process_time:.3f}s, "
                f"concurrent connections: {self.metrics.connection_count}"
            )
            raise
        finally:
            self.metrics.connection_count -= 1
