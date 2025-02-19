from typing import Optional, Dict, Any, List
import json

class MockWebSocket:
    def __init__(self):
        self.connected = False
        self.sent_messages: List[str] = []
        self.closed = False
        
    async def accept(self):
        self.connected = True
        
    async def close(self):
        self.connected = False
        self.closed = True
        
    async def send_json(self, data: Dict[str, Any]):
        self.sent_messages.append(json.dumps(data))
        
    def is_connected(self) -> bool:
        return self.connected
        
    async def receive_json(self) -> Dict[str, Any]:
        return {"type": "message", "content": "test"}
        
    async def send_text(self, text: str):
        self.sent_messages.append(text)
