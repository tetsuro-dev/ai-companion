import Foundation
import AVFoundation

@MainActor
class AudioPlaybackViewModel: ObservableObject {
    @Published var isPlaying = false
    @Published var progress: Double = 0
    @Published var errorMessage: String?
    
    private let audioService: AudioPlaybackService
    
    init() {
        let webSocketService = WebSocketService()
        self.audioService = AudioPlaybackService(webSocketService: webSocketService)
    }
    
    func playTTS(text: String) async {
        do {
            try await audioService.connect()
            try await audioService.playTTS(text: text)
            isPlaying = true
            errorMessage = nil
        } catch {
            errorMessage = "再生に失敗しました: \(error.localizedDescription)"
            isPlaying = false
        }
    }
    
    func stopPlayback() {
        audioService.disconnect()
        isPlaying = false
        progress = 0
    }
}
