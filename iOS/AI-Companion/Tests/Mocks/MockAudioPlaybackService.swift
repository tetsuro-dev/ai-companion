import Foundation
@testable import AI_Companion

class MockAudioPlaybackService: AudioPlaybackServiceProtocol {
    var playCallCount = 0
    var stopCallCount = 0
    var isPlayingValue = false
    var durationValue: TimeInterval = 30.0
    var currentTimeValue: TimeInterval = 0.0
    var shouldThrowError = false
    
    func play(data: Data) throws {
        playCallCount += 1
        if shouldThrowError {
            throw AudioPlaybackError.playbackFailed(NSError(domain: "Test", code: -1))
        }
        isPlayingValue = true
    }
    
    func stop() {
        stopCallCount += 1
        isPlayingValue = false
        currentTimeValue = 0
    }
    
    func isPlaying() -> Bool {
        return isPlayingValue
    }
    
    var duration: TimeInterval {
        return durationValue
    }
    
    var currentTime: TimeInterval {
        get { return currentTimeValue }
        set { currentTimeValue = newValue }
    }
}
