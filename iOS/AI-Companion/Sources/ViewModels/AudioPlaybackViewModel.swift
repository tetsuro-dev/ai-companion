import Foundation
import AVFoundation
import os.log

/// ViewModel responsible for managing TTS playback state and user interface
@MainActor
class AudioPlaybackViewModel: ObservableObject {
    @Published var isPlaying = false
    @Published var progress: Double = 0
    @Published var errorMessage: String?
    
    private let audioService: AudioPlaybackService
    private let logger = Logger(subsystem: "com.ai-companion", category: "AudioPlaybackViewModel")
    
    init() {
        let webSocketService = WebSocketService()
        self.audioService = AudioPlaybackService(webSocketService: webSocketService)
        logger.info("AudioPlaybackViewModel initialized")
    }
    
    /// Plays text using TTS
    /// - Parameter text: The text to convert to speech
    func playTTS(text: String) async {
        do {
            try await audioService.connect()
            try await audioService.playTTS(text: text)
            isPlaying = true
            errorMessage = nil
            logger.info("Started TTS playback: \(text)")
        } catch {
            errorMessage = "再生に失敗しました: \(error.localizedDescription)"
            isPlaying = false
            logger.error("TTS playback failed: \(error.localizedDescription)")
        }
    }
    
    /// Stops the current audio playback
    func stopPlayback() {
        audioService.disconnect()
        isPlaying = false
        progress = 0
        logger.info("Stopped playback")
    }
    
    deinit {
        stopPlayback()
        logger.info("AudioPlaybackViewModel deallocated")
    }
}
