import Foundation
import Combine

class WebSocketService {
    @Published private(set) var state: ConnectionState = .disconnected
    private var reconnectionStrategy: ReconnectionStrategy
    private var reconnectionAttempt: Int = 0
    private var reconnectionTask: Task<Void, Never>?
    private var endpoint: String?
    
    var webSocketTask: URLSessionWebSocketTask?
    private let baseURL = "ws://localhost:8000"
    
    init(reconnectionStrategy: ReconnectionStrategy = ExponentialBackoff()) {
        self.reconnectionStrategy = reconnectionStrategy
    }
    
    func connect(to endpoint: String) throws {
        self.endpoint = endpoint
        try establishConnection()
    }
    
    private func establishConnection() throws {
        guard let endpoint = endpoint,
              let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw WebSocketError.invalidURL
        }
        
        state = .connecting
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        startListeningForMessages()
        state = .connected
        reconnectionAttempt = 0
    }
    
    private func startListeningForMessages() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    self.handleAvatarEvent(data)
                case .string(let string):
                    if let data = string.data(using: .utf8) {
                        self.handleAvatarEvent(data)
                    }
                @unknown default:
                    break
                }
                self.startListeningForMessages()
            case .failure:
                self.handleDisconnection()
            }
        }
    }
    
    private func handleDisconnection() {
        guard state != .disconnected else { return }
        
        state = .reconnecting
        reconnectionTask?.cancel()
        reconnectionTask = Task {
            let delay = reconnectionStrategy.nextDelay(attempt: reconnectionAttempt)
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            
            if !Task.isCancelled {
                reconnectionAttempt += 1
                try? establishConnection()
            }
        }
    }
    
    func disconnect() {
        reconnectionTask?.cancel()
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        state = .disconnected
        endpoint = nil
    }
    
    func send(_ data: Data) async throws {
        guard let task = webSocketTask else {
            throw WebSocketError.connectionFailed
        }
        
        do {
            let message = URLSessionWebSocketTask.Message.data(data)
            try await task.send(message)
        } catch {
            handleDisconnection()
            throw WebSocketError.sendFailed(error)
        }
    }
    
    func receive() async throws -> URLSessionWebSocketTask.Message {
        guard let task = webSocketTask else {
            throw WebSocketError.connectionFailed
        }
        
        do {
            return try await task.receive()
        } catch {
            handleDisconnection()
            throw WebSocketError.receiveFailed(error)
        }
    }
}
