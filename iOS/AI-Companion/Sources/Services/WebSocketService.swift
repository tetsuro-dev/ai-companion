import Foundation

enum WebSocketError: Error {
    case connectionFailed
    case sendFailed(Error)
    case receiveFailed(Error)
    case invalidURL
}

class WebSocketService {
    private var webSocketTask: URLSessionWebSocketTask?
    private let baseURL = "ws://localhost:8000"
    
    func connect(to endpoint: String) throws {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw WebSocketError.invalidURL
        }
        
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
    }
    
    func send(_ data: Data) async throws {
        guard let task = webSocketTask else {
            throw WebSocketError.connectionFailed
        }
        
        let message = URLSessionWebSocketTask.Message.data(data)
        try await task.send(message)
    }
    
    func receive() async throws -> String {
        guard let task = webSocketTask else {
            throw WebSocketError.connectionFailed
        }
        
        let message = try await task.receive()
        switch message {
        case .string(let text):
            return text
        case .data:
            throw WebSocketError.receiveFailed(NSError(domain: "", code: -1))
        @unknown default:
            throw WebSocketError.receiveFailed(NSError(domain: "", code: -1))
        }
    }
}
