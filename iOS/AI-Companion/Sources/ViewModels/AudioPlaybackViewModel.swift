import Foundation
import AVFoundation
import os.log
import Combine

/// ViewModel responsible for managing TTS playback state and user interface
@MainActor
class AudioPlaybackViewModel: ObservableObject {
    @Published var isPlaying = false
    @Published var progress: Double = 0
    @Published var errorMessage: String?
    @Published var connectionState: ConnectionState = .disconnected
    
    private let audioService: AudioPlaybackService
    private let webSocketService: WebSocketService
    private let logger = Logger(subsystem: "com.ai-companion", category: "AudioPlaybackViewModel")
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let webSocketService = WebSocketService()
        self.webSocketService = webSocketService
        self.audioService = AudioPlaybackService(webSocketService: webSocketService)
        
        setupSubscriptions()
        logger.info("AudioPlaybackViewModel initialized")
    }
    
    private func setupSubscriptions() {
        webSocketService.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.connectionState = state
                self?.handleConnectionStateChange(state)
            }
            .store(in: &cancellables)
    }
    
    private func handleConnectionStateChange(_ state: ConnectionState) {
        switch state {
        case .disconnected:
            errorMessage = "接続が切断されました"
            isPlaying = false
        case .connecting:
            errorMessage = "接続中..."
        case .connected:
            errorMessage = nil
        case .reconnecting:
            errorMessage = "再接続中..."
            isPlaying = false
        }
    }
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
