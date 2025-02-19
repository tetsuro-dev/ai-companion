from enum import Enum
from typing import Optional, Dict

class WebSocketErrorCode(Enum):
    CONNECTION_ERROR = 1000
    INVALID_MESSAGE = 1001
    TIMEOUT = 1002
    RATE_LIMIT = 1003
    SERVER_ERROR = 1004

class WebSocketError(Exception):
    def __init__(self, code: WebSocketErrorCode, message: str, details: Optional[Dict] = None):
        self.code = code
        self.message = message
        self.details = details or {}
        super().__init__(message)

    @classmethod
    def connection_error(cls) -> "WebSocketError":
        return cls(
            WebSocketErrorCode.CONNECTION_ERROR,
            "接続エラーが発生しました。再接続を試みています。"
        )

    @classmethod
    def invalid_message(cls) -> "WebSocketError":
        return cls(
            WebSocketErrorCode.INVALID_MESSAGE,
            "無効なメッセージ形式です。"
        )

    @classmethod
    def timeout(cls) -> "WebSocketError":
        return cls(
            WebSocketErrorCode.TIMEOUT,
            "接続がタイムアウトしました。"
        )

    @classmethod
    def rate_limit(cls) -> "WebSocketError":
        return cls(
            WebSocketErrorCode.RATE_LIMIT,
            "リクエスト制限を超えました。しばらく待ってから再試行してください。"
        )

    @classmethod
    def server_error(cls, details: Optional[Dict] = None) -> "WebSocketError":
        return cls(
            WebSocketErrorCode.SERVER_ERROR,
            "サーバーエラーが発生しました。",
            details
        )

    def to_dict(self) -> Dict:
        return {
            "code": self.code.value,
            "message": self.message,
            "details": self.details
        }
