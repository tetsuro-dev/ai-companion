import Foundation
import Combine
import os.log

@MainActor
class ChatViewModel: ObservableObject {
    @Published private(set) var messages: [Message] = []
    @Published var inputMessage: String = ""
    @Published private(set) var isLoading: Bool = false
    
    private let apiClient: APIClient = .shared
    private let audioPlaybackViewModel: AudioPlaybackViewModel
    private let logger = Logger(subsystem: "com.ai-companion", category: "ChatViewModel")
    
    init(audioPlaybackViewModel: AudioPlaybackViewModel) {
        self.audioPlaybackViewModel = audioPlaybackViewModel
        logger.info("ChatViewModel initialized")
    }
    
    func sendMessage() async {
        guard !inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = Message(content: inputMessage, isFromUser: true)
        messages.append(userMessage)
        let messageToSend = inputMessage
        inputMessage = ""
        isLoading = true
        logger.info("Sending message: \(messageToSend)")
        
        do {
            let response: [String: Any] = try await apiClient.request("chat", method: "POST")
            if let content = response["message"] as? String {
                let aiMessage = Message(content: content, isFromUser: false)
                messages.append(aiMessage)
                logger.info("Received AI response, playing TTS")
                // Play TTS for AI response
                await audioPlaybackViewModel.playTTS(text: content)
            }
        } catch {
            logger.error("Failed to send message: \(error.localizedDescription)")
            // TODO: Add user-facing error message
        }
        
        isLoading = false
    }
}
