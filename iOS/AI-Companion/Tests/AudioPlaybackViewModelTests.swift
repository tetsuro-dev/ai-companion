import XCTest
@testable import AI_Companion

@MainActor
class AudioPlaybackViewModelTests: XCTestCase {
    var sut: AudioPlaybackViewModel!
    var mockWebSocketService: MockWebSocketService!
    
    override func setUp() async throws {
        super.setUp()
        mockWebSocketService = MockWebSocketService()
        sut = AudioPlaybackViewModel()
        // Replace WebSocketService with mock
        let mirror = Mirror(reflecting: sut.audioService)
        if let webSocketServiceProperty = mirror.children.first(where: { $0.label == "webSocketService" }) {
            // Hack to set private property for testing
            let webSocketServiceObject = webSocketServiceProperty.value as AnyObject
            webSocketServiceObject.setValue(mockWebSocketService, forKey: "webSocketService")
        }
    }
    
    override func tearDown() {
        sut = nil
        mockWebSocketService = nil
        super.tearDown()
    }
    
    func testPlayTTSSuccess() async {
        // Given
        let text = "Hello"
        let mockAudioData = Data(repeating: 0, count: 1024)
        mockWebSocketService.mockAudioData = mockAudioData
        
        // When
        await sut.playTTS(text: text)
        
        // Then
        XCTAssertTrue(sut.isPlaying)
        XCTAssertNil(sut.errorMessage)
        XCTAssertTrue(mockWebSocketService.didSendMessage)
    }
    
    func testPlayTTSFailureConnection() async {
        // Given
        let text = "Hello"
        mockWebSocketService.shouldThrowError = true
        
        // When
        await sut.playTTS(text: text)
        
        // Then
        XCTAssertFalse(sut.isPlaying)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.errorMessage?.contains("再生に失敗しました") ?? false)
    }
    
    func testPlayTTSFailureInvalidData() async {
        // Given
        let text = "Hello"
        mockWebSocketService.shouldReturnInvalidData = true
        
        // When
        await sut.playTTS(text: text)
        
        // Then
        XCTAssertFalse(sut.isPlaying)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.errorMessage?.contains("再生に失敗しました") ?? false)
    }
    
    func testStopPlayback() async {
        // Given
        let text = "Hello"
        let mockAudioData = Data(repeating: 0, count: 1024)
        mockWebSocketService.mockAudioData = mockAudioData
        await sut.playTTS(text: text)
        XCTAssertTrue(sut.isPlaying)
        
        // When
        sut.stopPlayback()
        
        // Then
        XCTAssertFalse(sut.isPlaying)
        XCTAssertEqual(sut.progress, 0)
        XCTAssertFalse(mockWebSocketService.isConnected)
    }
    
    func testConnectionLostDuringPlayback() async {
        // Given
        let text = "Hello"
        mockWebSocketService.shouldDisconnectDuringOperation = true
        
        // When
        await sut.playTTS(text: text)
        
        // Then
        XCTAssertFalse(sut.isPlaying)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.errorMessage?.contains("再生に失敗しました") ?? false)
    }
    
    func testCleanupOnDeinit() async {
        // Given
        let text = "Hello"
        let mockAudioData = Data(repeating: 0, count: 1024)
        mockWebSocketService.mockAudioData = mockAudioData
        await sut.playTTS(text: text)
        XCTAssertTrue(sut.isPlaying)
        
        // When
        sut = nil
        
        // Then
        XCTAssertFalse(mockWebSocketService.isConnected)
    }
}
