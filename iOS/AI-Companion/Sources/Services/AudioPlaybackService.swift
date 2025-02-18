import Foundation
import AVFoundation

enum AudioPlaybackError: Error {
    case playbackFailed(Error)
    case invalidAudioData
}

class AudioPlaybackService {
    private var audioPlayer: AVAudioPlayer?
    private let webSocketService: WebSocketService
    private var isConnected = false
    
    init(webSocketService: WebSocketService) {
        self.webSocketService = webSocketService
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func connect() async throws {
        try webSocketService.connect(to: "speech/synthesize")
        isConnected = true
    }
    
    func disconnect() {
        webSocketService.disconnect()
        stopPlayback()
        isConnected = false
    }
    
    func playTTS(text: String) async throws {
        if !isConnected {
            try await connect()
        }
        
        let message = ["text": text]
        let data = try JSONSerialization.data(withJSONObject: message)
        try await webSocketService.send(data)
        
        let audioData = try await receiveAudioData()
        try await play(audioData: audioData)
    }
    
    private func receiveAudioData() async throws -> Data {
        let message = try await webSocketService.receive()
        switch message {
        case .data(let audioData):
            return audioData
        case .string, _:
            throw AudioPlaybackError.invalidAudioData
        }
    }
    
    private func play(audioData: Data) async throws {
        stopPlayback()
        do {
            audioPlayer = try AVAudioPlayer(data: audioData)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            throw AudioPlaybackError.playbackFailed(error)
        }
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}
