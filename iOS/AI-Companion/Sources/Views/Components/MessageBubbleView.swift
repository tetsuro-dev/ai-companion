import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
            }
            
            Text(message.content)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(message.isFromUser ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(message.isFromUser ? .white : .primary)
                .cornerRadius(16)
                .padding(.horizontal, 8)
            
            if !message.isFromUser {
                Spacer()
            }
        }
    }
}
