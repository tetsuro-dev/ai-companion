import asyncio
import logging
from datetime import datetime, timedelta
from typing import Optional

from .manager import ConnectionManager

logger = logging.getLogger(__name__)

async def heartbeat_monitor(manager: ConnectionManager):
    """Background task to monitor WebSocket connections and send heartbeats.
    
    Maintains connection health by:
    - Monitoring last heartbeat timestamps
    - Disconnecting stale connections (>60s without heartbeat)
    - Sending heartbeats every 30s
    """
    while True:
        try:
            start_time = datetime.now()
            
            # Check for stale connections
            now = datetime.now()
            stale_clients = [
                client_id for client_id, last_beat in manager.last_heartbeat.items()
                if now - last_beat > timedelta(seconds=manager.CONNECTION_TIMEOUT)
            ]
            
            # Disconnect stale clients
            for client_id in stale_clients:
                logger.warning(f"Disconnecting stale client {client_id} (no heartbeat for >{manager.CONNECTION_TIMEOUT}s)")
                await manager.disconnect(client_id)
            
            # Send heartbeats to active connections
            active_count = manager.get_active_connections_count()
            if active_count > 0:
                logger.info(f"Monitoring {active_count} active connections")
                
            # Sleep for the heartbeat interval
            process_time = (datetime.now() - start_time).total_seconds()
            if process_time > 0.1:  # 100ms threshold
                logger.warning(f"Heartbeat monitor exceeded latency threshold: {process_time:.3f}s")
                
            sleep_time = max(0, manager.HEARTBEAT_INTERVAL - process_time)
            await asyncio.sleep(sleep_time)
            
        except Exception as e:
            logger.error(f"Error in heartbeat monitor: {str(e)}")
            await asyncio.sleep(1)  # Brief pause before retry
