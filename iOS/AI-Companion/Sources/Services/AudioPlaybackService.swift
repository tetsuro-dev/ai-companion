import AVFoundation
import os.log

/// Represents possible errors that can occur during audio playback operations
enum AudioPlaybackError: Error {
    /// Indicates a failure during audio playback with the underlying error
    case playbackFailed(Error)
    /// Indicates a failure in audio session setup
    case sessionSetupFailed(Error)
}

/// Protocol defining the interface for audio playback services.
/// This protocol allows for different implementations (e.g., direct playback, TTS, streaming)
/// while maintaining a consistent interface for the view models.
protocol AudioPlaybackServiceProtocol {
    /// Plays the provided audio data
    /// - Parameter data: The audio data to play
    /// - Throws: AudioPlaybackError if playback fails
    func play(data: Data) throws
    
    /// Stops the current audio playback
    func stop()
    
    /// Checks if audio is currently playing
    /// - Returns: true if audio is playing, false otherwise
    func isPlaying() -> Bool
    
    /// The duration of the current audio in seconds
    var duration: TimeInterval { get }
    
    /// The current playback position in seconds
    var currentTime: TimeInterval { get set }
}

/// Service responsible for handling audio playback functionality.
/// This implementation uses AVAudioPlayer for direct audio file playback.
class AudioPlaybackService: NSObject, AudioPlaybackServiceProtocol, AVAudioPlayerDelegate {
    /// Shared instance for singleton access
    static let shared = AudioPlaybackService()
    
    private var audioPlayer: AVAudioPlayer?
    private var logger = Logger(subsystem: "com.ai-companion", category: "AudioPlayback")
    
    private override init() {
        super.init()
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
            // We log the error but don't throw since this is called from init
            // Errors will surface when trying to play audio
        }
    }
    
    /// Plays the provided audio data
    /// - Parameter data: The audio data to play
    /// - Throws: AudioPlaybackError if playback fails
    func play(data: Data) throws {
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            
            guard audioPlayer?.play() == true else {
                logger.error("Failed to start audio playback")
                throw AudioPlaybackError.playbackFailed(NSError(domain: "AudioPlayback", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to start audio playback"]))
            }
            
            logger.info("Started audio playback successfully")
        } catch {
            logger.error("Failed to initialize audio player: \(error.localizedDescription)")
            throw AudioPlaybackError.playbackFailed(error)
        }
    }
    
    /// Stops the current audio playback
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        logger.info("Stopped audio playback")
    }
    
    /// Checks if audio is currently playing
    /// - Returns: true if audio is playing, false otherwise
    func isPlaying() -> Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    /// The duration of the current audio in seconds
    var duration: TimeInterval {
        return audioPlayer?.duration ?? 0
    }
    
    /// The current playback position in seconds
    var currentTime: TimeInterval {
        get { return audioPlayer?.currentTime ?? 0 }
        set { audioPlayer?.currentTime = newValue }
    }
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if !flag {
            logger.error("Audio playback finished unsuccessfully")
        } else {
            logger.info("Audio playback finished successfully")
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            logger.error("Audio decode error occurred: \(error.localizedDescription)")
        }
    }
}
