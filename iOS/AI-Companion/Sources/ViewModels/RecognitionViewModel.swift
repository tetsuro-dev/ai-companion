import Foundation
import Combine

@MainActor
final class RecognitionViewModel: ObservableObject {
    @Published var recognizedText: String = ""
    @Published var isConnected: Bool = false
    @Published var errorMessage: String?
    @Published var connectionState: ConnectionState = .disconnected
    
    private let webSocketService: WebSocketService
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.webSocketService = WebSocketService()
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        webSocketService.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.connectionState = state
                self?.isConnected = state == .connected
                self?.handleConnectionStateChange(state)
            }
            .store(in: &cancellables)
    }
    
    private func handleConnectionStateChange(_ state: ConnectionState) {
        switch state {
        case .disconnected:
            errorMessage = "接続が切断されました"
        case .connecting:
            errorMessage = "接続中..."
        case .connected:
            errorMessage = nil
        case .reconnecting:
            errorMessage = "再接続中..."
        }
    }
    
    func startRecognition() {
        Task {
            do {
                try webSocketService.connect(to: "speech/recognize")
                startListening()
            } catch {
                errorMessage = "接続に失敗しました: \(error.localizedDescription)"
            }
        }
    }
    
    func stopRecognition() {
        webSocketService.disconnect()
    }
    
    private func startListening() {
        Task { [weak self] in
            do {
                while self?.connectionState == .connected {
                    guard let result = try await self?.webSocketService.receive() else { continue }
                    
                    switch result {
                    case .string(let jsonString):
                        if let data = jsonString.data(using: .utf8),
                           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let text = json["text"] as? String {
                            await MainActor.run {
                                self?.recognizedText = text
                            }
                        }
                    default:
                        break
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
