import Foundation
import AVFoundation

@MainActor
class AudioRecordingViewModel: ObservableObject {
    @Published var isRecording = false
    @Published var hasPermission = false
    @Published var errorMessage: String?
    
    private let audioService: AudioRecordingService
    
    init() {
        self.audioService = AudioRecordingService()
        Task {
            await checkPermissions()
        }
    }
    
    private func checkPermissions() async {
        let status = await AVAudioSession.sharedInstance().recordPermission
        hasPermission = status == .granted
        
        if status == .undetermined {
            hasPermission = await withCheckedContinuation { continuation in
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        }
    }
    
    func startRecording() {
        guard hasPermission else {
            errorMessage = "マイクの許可が必要です。"
            return
        }
        
        do {
            try audioService.startRecording()
            isRecording = true
            errorMessage = nil
        } catch {
            errorMessage = "録音の開始に失敗しました: \(error.localizedDescription)"
        }
    }
    
    func stopRecording() {
        audioService.stopRecording()
        isRecording = false
    }
}
