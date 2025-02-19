import Foundation

enum WebSocketError: Error {
    case connectionFailed
    case sendFailed(Error)
    case receiveFailed(Error)
    case invalidURL
    case reconnectionFailed
    case connectionCancelled
    case invalidState(String)
    case timeout
}

extension WebSocketError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .connectionFailed:
            return "Failed to establish WebSocket connection"
        case .sendFailed(let error):
            return "Failed to send message: \(error.localizedDescription)"
        case .receiveFailed(let error):
            return "Failed to receive message: \(error.localizedDescription)"
        case .invalidURL:
            return "Invalid WebSocket URL"
        case .reconnectionFailed:
            return "Failed to reconnect after multiple attempts"
        case .connectionCancelled:
            return "WebSocket connection was cancelled"
        case .invalidState(let state):
            return "Invalid WebSocket state: \(state)"
        case .timeout:
            return "WebSocket operation timed out"
        }
    }
}
