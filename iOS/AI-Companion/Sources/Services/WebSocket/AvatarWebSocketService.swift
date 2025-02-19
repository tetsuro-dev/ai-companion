import Foundation

// MARK: - Avatar Control Events
extension WebSocketService {
    static let shared = WebSocketService(reconnectionStrategy: ExponentialBackoff())
    
    func sendAvatarEvent(_ event: [String: Any]) async throws {
        let data = try JSONSerialization.data(withJSONObject: event)
        try await send(data)
    }
    
    func sendAvatarExpression(_ expression: String) async throws {
        let event: [String: Any] = [
            "type": "avatar_expression",
            "expression": expression
        ]
        try await sendAvatarEvent(event)
    }
    
    func sendAvatarLipSync(_ value: Float) async throws {
        let event: [String: Any] = [
            "type": "avatar_lip_sync",
            "value": value
        ]
        try await sendAvatarEvent(event)
    }
}

// MARK: - Avatar WebSocket Events
extension WebSocketService {
    func handleAvatarEvent(_ data: Data) {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["type"] as? String else {
            return
        }
        
        switch type {
        case "avatar_expression_response":
            if let expression = json["expression"] as? String {
                NotificationCenter.default.post(
                    name: .avatarExpressionUpdated,
                    object: nil,
                    userInfo: ["expression": expression]
                )
            }
        case "avatar_lip_sync_response":
            if let value = json["value"] as? Float {
                NotificationCenter.default.post(
                    name: .avatarLipSyncUpdated,
                    object: nil,
                    userInfo: ["value": value]
                )
            }
        default:
            break
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let avatarExpressionUpdated = Notification.Name("avatarExpressionUpdated")
    static let avatarLipSyncUpdated = Notification.Name("avatarLipSyncUpdated")
}
