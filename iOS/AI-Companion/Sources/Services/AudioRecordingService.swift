import Foundation
import AVFoundation

class AudioRecordingService {
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    
    private let targetSampleRate: Double = 16000
    private let bufferSize: AVAudioFrameCount = 1024
    
    init() {
        setupAudioSession()
        setupAudioEngine()
    }
    
    private func setupAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default)
        try session.setActive(true)
    }
    
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        inputNode = audioEngine?.inputNode
        
        let inputFormat = inputNode?.outputFormat(forBus: 0)
        let recordingFormat = AVAudioFormat(
            commonFormat: .pcmFormatInt16,
            sampleRate: targetSampleRate,
            channels: 1,
            interleaved: true
        )
        
        guard let inputFormat = inputFormat, let recordingFormat = recordingFormat else { return }
        
        let converter = AVAudioConverter(from: inputFormat, to: recordingFormat)
        
        inputNode?.installTap(onBus: 0, bufferSize: bufferSize, format: inputFormat) { [weak self] buffer, time in
            // Convert buffer to correct format and prepare for sending
            guard let converter = converter else { return }
            let convertedBuffer = AVAudioPCMBuffer(
                pcmFormat: recordingFormat,
                frameCapacity: AVAudioFrameCount(recordingFormat.sampleRate * Double(buffer.frameLength) / inputFormat.sampleRate)
            )
            
            var error: NSError?
            converter.convert(to: convertedBuffer!, error: &error) { inNumPackets, outStatus in
                return .haveData
            }
            
            if let error = error {
                print("Conversion error: \(error)")
                return
            }
            
            // Store converted buffer for sending
            self?.processAudioBuffer(convertedBuffer!)
        }
    }
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        // Store buffer data for sending to backend
        // This will be implemented in the next subtask
    }
    
    func startRecording() throws {
        guard let audioEngine = audioEngine else { return }
        try audioEngine.start()
    }
    
    func stopRecording() {
        audioEngine?.stop()
        inputNode?.removeTap(onBus: 0)
    }
}
