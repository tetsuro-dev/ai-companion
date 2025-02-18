import Foundation
import AVFoundation

class AudioPlaybackService {
    private var audioPlayer: AVAudioPlayer?
    private let webSocketService: WebSocketService
    
    init(webSocketService: WebSocketService) {
        self.webSocketService = webSocketService
    }
    
    func connect() async throws {
        try webSocketService.connect(to: "speech/synthesize")
    }
    
    func disconnect() {
        webSocketService.disconnect()
        stopPlayback()
    }
    
    func playTTS(text: String) async throws {
        let message = ["text": text]
        let data = try JSONSerialization.data(withJSONObject: message)
        try await webSocketService.send(data)
        
        if let audioData = try await receiveAudioData() {
            try await play(audioData: audioData)
        }
    }
    
    private func receiveAudioData() async throws -> Data? {
        guard let task = webSocketService.webSocketTask else {
            throw WebSocketError.connectionFailed
        }
        
        let message = try await task.receive()
        switch message {
        case .data(let audioData):
            return audioData
        default:
            throw WebSocketError.receiveFailed(NSError(domain: "", code: -1))
        }
    }
    
    private func play(audioData: Data) async throws {
        stopPlayback()
        audioPlayer = try AVAudioPlayer(data: audioData)
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}
