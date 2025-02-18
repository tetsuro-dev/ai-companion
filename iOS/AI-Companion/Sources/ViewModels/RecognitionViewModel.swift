import Foundation

@MainActor
class RecognitionViewModel: ObservableObject {
    @Published var recognizedText: String = ""
    @Published var isConnected: Bool = false
    @Published var errorMessage: String?
    
    private let webSocketService: WebSocketService
    
    init() {
        self.webSocketService = WebSocketService()
    }
    
    func startRecognition() {
        do {
            try webSocketService.connect(to: "speech/recognize")
            isConnected = true
            errorMessage = nil
            startListening()
        } catch {
            errorMessage = "接続に失敗しました: \(error.localizedDescription)"
        }
    }
    
    func stopRecognition() {
        webSocketService.disconnect()
        isConnected = false
    }
    
    private func startListening() {
        Task { [weak self] in
            do {
                while self?.isConnected == true {
                    if let result = try? await self?.webSocketService.receive(),
                       let data = result.data(using: .utf8),
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let text = json["text"] as? String {
                        await MainActor.run {
                            self?.recognizedText = text
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    self?.errorMessage = "認識エラー: \(error.localizedDescription)"
                }
            }
        }
    }
}
