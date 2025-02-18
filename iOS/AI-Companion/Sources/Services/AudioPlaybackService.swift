import Foundation
import AVFoundation
import os.log

/// Represents possible errors that can occur during audio playback operations
enum AudioPlaybackError: Error {
    /// Indicates a failure during audio playback with the underlying error
    case playbackFailed(Error)
    /// Indicates a failure in audio session setup
    case sessionSetupFailed(Error)
    /// Indicates invalid audio data was received
    case invalidAudioData
}

/// Service responsible for handling audio playback functionality using WebSocket-based TTS.
class AudioPlaybackService {
    private var audioPlayer: AVAudioPlayer?
    private let webSocketService: WebSocketService
    private var isConnected = false
    private let logger = Logger(subsystem: "com.ai-companion", category: "AudioPlayback")
    
    init(webSocketService: WebSocketService) {
        self.webSocketService = webSocketService
        setupAudioSession()
    }
    
    /// Sets up the audio session for playback
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
            logger.info("Audio session setup completed successfully")
        } catch {
            logger.error("Failed to setup audio session: \(error.localizedDescription)")
        }
    }
    
    /// Connects to the TTS WebSocket service
    /// - Throws: WebSocketError if connection fails
    func connect() async throws {
        try webSocketService.connect(to: "speech/synthesize")
        isConnected = true
        logger.info("Connected to TTS service")
    }
    
    /// Disconnects from the TTS WebSocket service and stops playback
    func disconnect() {
        webSocketService.disconnect()
        stopPlayback()
        isConnected = false
        logger.info("Disconnected from TTS service")
    }
    
    /// Plays text using TTS through WebSocket
    /// - Parameter text: The text to convert to speech
    /// - Throws: AudioPlaybackError or WebSocketError if playback fails
    func playTTS(text: String) async throws {
        if !isConnected {
            try await connect()
        }
        
        let message = ["text": text]
        let data = try JSONSerialization.data(withJSONObject: message)
        try await webSocketService.send(data)
        logger.info("Sent TTS request: \(text)")
        
        let audioData = try await receiveAudioData()
        try await play(audioData: audioData)
    }
    
    /// Receives audio data from the WebSocket
    /// - Returns: The received audio data
    /// - Throws: AudioPlaybackError if invalid data is received
    private func receiveAudioData() async throws -> Data {
        let message = try await webSocketService.receive()
        switch message {
        case .data(let audioData):
            logger.info("Received audio data")
            return audioData
        case .string, _:
            logger.error("Received invalid audio data")
            throw AudioPlaybackError.invalidAudioData
        }
    }
    
    /// Plays the provided audio data
    /// - Parameter audioData: The audio data to play
    /// - Throws: AudioPlaybackError if playback fails
    private func play(audioData: Data) async throws {
        stopPlayback()
        do {
            audioPlayer = try AVAudioPlayer(data: audioData)
            audioPlayer?.prepareToPlay()
            guard audioPlayer?.play() == true else {
                logger.error("Failed to start audio playback")
                throw AudioPlaybackError.playbackFailed(NSError(domain: "AudioPlayback", code: -1))
            }
            logger.info("Started audio playback")
        } catch {
            logger.error("Failed to initialize audio player: \(error.localizedDescription)")
            throw AudioPlaybackError.playbackFailed(error)
        }
    }
    
    /// Stops the current audio playback
    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        logger.info("Stopped audio playback")
    }
}
