import AVFoundation

class AudioPlaybackService {
    static let shared = AudioPlaybackService()
    private var audioPlayer: AVAudioPlayer?
    
    private init() {}
    
    func play(data: Data) throws {
        audioPlayer = try AVAudioPlayer(data: data)
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    func isPlaying() -> Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    var duration: TimeInterval {
        return audioPlayer?.duration ?? 0
    }
    
    var currentTime: TimeInterval {
        get { return audioPlayer?.currentTime ?? 0 }
        set { audioPlayer?.currentTime = newValue }
    }
}
