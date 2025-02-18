import Foundation
import Combine

@MainActor
class AudioPlaybackViewModel: ObservableObject {
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var progress: Double = 0
    @Published private(set) var errorMessage: String?
    
    private let playbackService: AudioPlaybackService = .shared
    private var progressTimer: Timer?
    
    func playAudio(data: Data) {
        do {
            try playbackService.play(data: data)
            isPlaying = true
            startProgressTracking()
        } catch {
            errorMessage = "音声の再生に失敗しました: \(error.localizedDescription)"
        }
    }
    
    func stopAudio() {
        playbackService.stop()
        isPlaying = false
        stopProgressTracking()
        progress = 0
    }
    
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
    }
    
    private func stopProgressTracking() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    deinit {
        stopProgressTracking()
    }
}
