import Foundation
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published private(set) var messages: [Message] = []
    @Published var inputMessage: String = ""
    @Published private(set) var isLoading: Bool = false
    
    private let apiClient: APIClient = .shared
    
    func sendMessage() async {
        guard !inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = Message(content: inputMessage, isFromUser: true)
        messages.append(userMessage)
        let messageToSend = inputMessage
        inputMessage = ""
        isLoading = true
        
        do {
            let response: [String: Any] = try await apiClient.request("chat", method: "POST")
            if let content = response["message"] as? String,
               let audioDataBase64 = response["audio"] as? String,
               let audioData = Data(base64Encoded: audioDataBase64) {
                let aiMessage = Message(content: content, isFromUser: false, audioData: audioData)
                messages.append(aiMessage)
            }
        } catch {
            print("Error: \(error)")
            // TODO: Add proper error handling
        }
        
        isLoading = false
    }
}
