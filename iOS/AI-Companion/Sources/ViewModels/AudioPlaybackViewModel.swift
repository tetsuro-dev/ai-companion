import Foundation
import Combine
import os.log

/// ViewModel responsible for managing audio playback state and user interface
@MainActor
class AudioPlaybackViewModel: ObservableObject {
    /// Published properties for UI binding
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var progress: Double = 0
    @Published private(set) var errorMessage: String?
    
    private let playbackService: AudioPlaybackServiceProtocol
    private var progressTimer: Timer?
    private let logger = Logger(subsystem: "com.ai-companion", category: "AudioPlaybackViewModel")
    
    /// Initializes the ViewModel with a playback service
    /// - Parameter service: The service to use for audio playback. Defaults to shared instance.
    init(service: AudioPlaybackServiceProtocol = AudioPlaybackService.shared) {
        self.playbackService = service
        logger.info("AudioPlaybackViewModel initialized")
    }
    
    /// Plays the provided audio data
    /// - Parameter data: The audio data to play
    func playAudio(data: Data) {
        do {
            try playbackService.play(data: data)
            isPlaying = true
            startProgressTracking()
            logger.info("Started playing audio")
        } catch let error as AudioPlaybackError {
            handlePlaybackError(error)
        } catch {
            handlePlaybackError(.playbackFailed(error))
        }
    }
    
    /// Stops the current audio playback
    func stopAudio() {
        playbackService.stop()
        isPlaying = false
        stopProgressTracking()
        progress = 0
        logger.info("Stopped audio playback")
    }
    
    /// Starts tracking playback progress
    private func startProgressTracking() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let duration = self.playbackService.duration
            if duration > 0 {
                self.progress = self.playbackService.currentTime / duration
            }
            if !self.playbackService.isPlaying() {
                self.stopAudio()
            }
        }
        logger.debug("Started progress tracking")
    }
    
    /// Stops tracking playback progress
    private func stopProgressTracking() {
        progressTimer?.invalidate()
        progressTimer = nil
        logger.debug("Stopped progress tracking")
    }
    
    /// Handles playback errors and updates UI accordingly
    private func handlePlaybackError(_ error: AudioPlaybackError) {
        logger.error("Playback error occurred: \(error.localizedDescription)")
        switch error {
        case .playbackFailed(let underlyingError):
            errorMessage = "音声の再生に失敗しました: \(underlyingError.localizedDescription)"
        case .sessionSetupFailed(let underlyingError):
            errorMessage = "オーディオセッションの設定に失敗しました: \(underlyingError.localizedDescription)"
        }
        isPlaying = false
        stopProgressTracking()
    }
    
    deinit {
        stopProgressTracking()
        logger.info("AudioPlaybackViewModel deallocated")
    }
}
