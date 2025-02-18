import XCTest
@testable import AI_Companion

class AudioPlaybackServiceTests: XCTestCase {
    var sut: AudioPlaybackService!
    var mockWebSocketService: MockWebSocketService!
    
    override func setUp() {
        super.setUp()
        mockWebSocketService = MockWebSocketService()
        sut = AudioPlaybackService(webSocketService: mockWebSocketService)
    }
    
    override func tearDown() {
        sut.stopPlayback()
        sut = nil
        mockWebSocketService = nil
        super.tearDown()
    }
    
    func testConnectSuccess() async throws {
        // When
        try await sut.connect()
        
        // Then
        XCTAssertTrue(mockWebSocketService.isConnected)
    }
    
    func testConnectFailure() async {
        // Given
        mockWebSocketService.shouldThrowError = true
        
        // When/Then
        do {
            try await sut.connect()
            XCTFail("Expected connection to fail")
        } catch {
            XCTAssertTrue(error is WebSocketError)
        }
    }
    
    func testDisconnect() async throws {
        // Given
        try await sut.connect()
        XCTAssertTrue(mockWebSocketService.isConnected)
        
        // When
        sut.disconnect()
        
        // Then
        XCTAssertFalse(mockWebSocketService.isConnected)
    }
    
    func testPlayTTSSuccess() async throws {
        // Given
        let text = "Hello"
        let mockAudioData = Data(repeating: 0, count: 1024)
        mockWebSocketService.mockAudioData = mockAudioData
        
        // When
        try await sut.playTTS(text: text)
        
        // Then
        XCTAssertTrue(mockWebSocketService.didSendMessage)
        XCTAssertTrue(mockWebSocketService.didReceiveMessage)
    }
    
    func testPlayTTSFailureInvalidData() async {
        // Given
        let text = "Hello"
        mockWebSocketService.shouldReturnInvalidData = true
        
        // When/Then
        do {
            try await sut.playTTS(text: text)
            XCTFail("Expected playTTS to fail")
        } catch let error as AudioPlaybackError {
            XCTAssertEqual(error, .invalidAudioData)
        }
    }
    
    func testPlayTTSFailureConnectionLost() async {
        // Given
        let text = "Hello"
        mockWebSocketService.shouldDisconnectDuringOperation = true
        
        // When/Then
        do {
            try await sut.playTTS(text: text)
            XCTFail("Expected playTTS to fail")
        } catch let error as WebSocketError {
            XCTAssertEqual(error, .connectionFailed)
        }
    }
    
    func testResourceCleanup() async throws {
        // Given
        try await sut.connect()
        let text = "Hello"
        let mockAudioData = Data(repeating: 0, count: 1024)
        mockWebSocketService.mockAudioData = mockAudioData
        try await sut.playTTS(text: text)
        
        // When
        sut.disconnect()
        
        // Then
        XCTAssertFalse(mockWebSocketService.isConnected)
    }
}
