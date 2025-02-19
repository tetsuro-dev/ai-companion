from typing import Dict, Optional
from fastapi import WebSocket
import logging
import asyncio
from datetime import datetime, timedelta

from .errors import WebSocketError, WebSocketErrorCode

logger = logging.getLogger(__name__)

class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[str, WebSocket] = {}
        self.last_heartbeat: Dict[str, datetime] = {}
        self.connection_states: Dict[str, str] = {}
        self.HEARTBEAT_INTERVAL = 30  # seconds
        self.CONNECTION_TIMEOUT = 60  # seconds
        self.MAX_RECONNECT_ATTEMPTS = 5
        self.MAX_CONNECTIONS = 5000
        
    async def connect(self, client_id: str, websocket: WebSocket) -> bool:
        if len(self.active_connections) >= self.MAX_CONNECTIONS:
            logger.warning(f"Connection limit reached ({self.MAX_CONNECTIONS})")
            return False
            
        if client_id in self.active_connections:
            raise WebSocketError(
                WebSocketErrorCode.INVALID_STATE,
                f"Client {client_id} is already connected"
            )
            
        await websocket.accept()
        self.active_connections[client_id] = websocket
        self.last_heartbeat[client_id] = datetime.now()
        self.connection_states[client_id] = "connected"
        logger.info(f"Client {client_id} connected. Active connections: {len(self.active_connections)}")
        return True
        
    async def disconnect(self, client_id: str):
        if client_id in self.active_connections:
            try:
                await self.active_connections[client_id].close()
            except Exception as e:
                logger.error(f"Error closing connection for client {client_id}: {str(e)}")
            finally:
                del self.active_connections[client_id]
                del self.last_heartbeat[client_id]
                del self.connection_states[client_id]
                logger.info(f"Client {client_id} disconnected. Active connections: {len(self.active_connections)}")
            
    async def send_heartbeat(self, client_id: str) -> bool:
        if client_id not in self.active_connections:
            raise WebSocketError(
                WebSocketErrorCode.CONNECTION_ERROR,
                f"Client {client_id} is not connected"
            )
            
        try:
            await self.active_connections[client_id].send_json({"type": "heartbeat"})
            self.last_heartbeat[client_id] = datetime.now()
            return True
        except Exception as e:
            logger.error(f"Heartbeat failed for client {client_id}: {str(e)}")
            await self.disconnect(client_id)
            return False
        
    def is_connected(self, client_id: str) -> bool:
        return client_id in self.active_connections
        
    def get_connection_state(self, client_id: str) -> Optional[str]:
        return self.connection_states.get(client_id)
        
    def get_active_connections_count(self) -> int:
        return len(self.active_connections)
        
    async def cleanup_stale_connections(self):
        now = datetime.now()
        stale_clients = [
            client_id for client_id, last_beat in self.last_heartbeat.items()
            if now - last_beat > timedelta(seconds=self.CONNECTION_TIMEOUT)
        ]
        for client_id in stale_clients:
            logger.warning(f"Cleaning up stale connection for client {client_id}")
            await self.disconnect(client_id)
            if client_id in self.active_connections:
                del self.active_connections[client_id]
                del self.last_heartbeat[client_id]
                del self.connection_states[client_id]
