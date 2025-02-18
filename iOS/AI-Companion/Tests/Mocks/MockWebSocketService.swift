import Foundation
@testable import AI_Companion

class MockWebSocketService: WebSocketService {
    var isConnected = false
    var didSendMessage = false
    var didReceiveMessage = false
    var shouldThrowError = false
    var shouldReturnInvalidData = false
    var shouldDisconnectDuringOperation = false
    var mockAudioData: Data?
    
    override func connect(to endpoint: String) throws {
        if shouldThrowError {
            throw WebSocketError.connectionFailed
        }
        isConnected = true
    }
    
    override func disconnect() {
        isConnected = false
    }
    
    override func send(_ data: Data) async throws {
        if shouldDisconnectDuringOperation {
            throw WebSocketError.connectionFailed
        }
        didSendMessage = true
    }
    
    override func receive() async throws -> URLSessionWebSocketTask.Message {
        if shouldDisconnectDuringOperation {
            throw WebSocketError.connectionFailed
        }
        
        didReceiveMessage = true
        
        if shouldReturnInvalidData {
            return .string("invalid data")
        }
        
        if let audioData = mockAudioData {
            return .data(audioData)
        }
        
        return .data(Data())
    }
}
