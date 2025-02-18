import XCTest
@testable import AI_Companion

@MainActor
class AudioPlaybackViewModelTests: XCTestCase {
    var sut: AudioPlaybackViewModel!
    var mockService: MockAudioPlaybackService!
    
    override func setUp() async throws {
        super.setUp()
        mockService = MockAudioPlaybackService()
        sut = AudioPlaybackViewModel(service: mockService)
    }
    
    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }
    
    func testPlayAudioSuccess() async {
        // Given
        let testData = Data(repeating: 0, count: 1024)
        
        // When
        sut.playAudio(data: testData)
        
        // Then
        XCTAssertEqual(mockService.playCallCount, 1)
        XCTAssertTrue(sut.isPlaying)
        XCTAssertNil(sut.errorMessage)
    }
    
    func testPlayAudioFailure() async {
        // Given
        let testData = Data(repeating: 0, count: 1024)
        mockService.shouldThrowError = true
        
        // When
        sut.playAudio(data: testData)
        
        // Then
        XCTAssertEqual(mockService.playCallCount, 1)
        XCTAssertFalse(sut.isPlaying)
        XCTAssertNotNil(sut.errorMessage)
    }
    
    func testStopAudio() async {
        // Given
        let testData = Data(repeating: 0, count: 1024)
        sut.playAudio(data: testData)
        XCTAssertTrue(sut.isPlaying)
        
        // When
        sut.stopAudio()
        
        // Then
        XCTAssertEqual(mockService.stopCallCount, 1)
        XCTAssertFalse(sut.isPlaying)
        XCTAssertEqual(sut.progress, 0)
    }
    
    func testProgressTracking() async {
        // Given
        let testData = Data(repeating: 0, count: 1024)
        
        // When
        sut.playAudio(data: testData)
        
        // Then
        XCTAssertTrue(sut.isPlaying)
        // Wait for progress update
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        XCTAssertGreaterThan(sut.progress, 0)
    }
    
    func testErrorMessageLocalization() async {
        // Given
        let testData = Data(repeating: 0, count: 1024)
        mockService.shouldThrowError = true
        
        // When
        sut.playAudio(data: testData)
        
        // Then
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.errorMessage?.contains("音声の再生に失敗しました") ?? false)
    }
}
