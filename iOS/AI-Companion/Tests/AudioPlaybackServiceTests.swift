import XCTest
@testable import AI_Companion

class AudioPlaybackServiceTests: XCTestCase {
    var sut: AudioPlaybackService!
    
    override func setUp() {
        super.setUp()
        sut = AudioPlaybackService.shared
    }
    
    override func tearDown() {
        sut.stop()
        sut = nil
        super.tearDown()
    }
    
    func testPlayValidAudioData() throws {
        // Given
        let validData = Data(repeating: 0, count: 1024) // Mock audio data
        
        // When
        try sut.play(data: validData)
        
        // Then
        XCTAssertTrue(sut.isPlaying())
        XCTAssertGreaterThan(sut.duration, 0)
    }
    
    func testPlayInvalidAudioData() {
        // Given
        let invalidData = Data() // Empty data
        
        // When/Then
        XCTAssertThrowsError(try sut.play(data: invalidData)) { error in
            XCTAssertTrue(error is AudioPlaybackError)
            if case AudioPlaybackError.playbackFailed = error {
                // Expected error
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
        }
    }
    
    func testStopPlayback() throws {
        // Given
        let validData = Data(repeating: 0, count: 1024)
        try sut.play(data: validData)
        XCTAssertTrue(sut.isPlaying())
        
        // When
        sut.stop()
        
        // Then
        XCTAssertFalse(sut.isPlaying())
        XCTAssertEqual(sut.currentTime, 0)
    }
    
    func testPlaybackProgress() throws {
        // Given
        let validData = Data(repeating: 0, count: 1024)
        
        // When
        try sut.play(data: validData)
        
        // Then
        XCTAssertGreaterThanOrEqual(sut.duration, 0)
        XCTAssertGreaterThanOrEqual(sut.currentTime, 0)
        XCTAssertLessThanOrEqual(sut.currentTime, sut.duration)
    }
    
    func testResourceCleanup() throws {
        // Given
        let validData = Data(repeating: 0, count: 1024)
        try sut.play(data: validData)
        
        // When
        sut.stop()
        
        // Then
        XCTAssertFalse(sut.isPlaying())
        XCTAssertEqual(sut.currentTime, 0)
        XCTAssertEqual(sut.duration, 0)
    }
}
