import Foundation

struct Message: Identifiable {
    let id: UUID
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    var audioData: Data?
    
    init(id: UUID = UUID(), content: String, isFromUser: Bool, timestamp: Date = Date(), audioData: Data? = nil) {
        self.id = id
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = timestamp
        self.audioData = audioData
    }
}
