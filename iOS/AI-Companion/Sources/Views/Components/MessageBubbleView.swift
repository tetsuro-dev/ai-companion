import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    @StateObject private var playbackViewModel = AudioPlaybackViewModel()
    
    var body: some View {
        VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
            HStack {
                if message.isFromUser {
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.content)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(message.isFromUser ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(message.isFromUser ? .white : .primary)
                        .cornerRadius(16)
                    
                    if let audioData = message.audioData {
                        HStack(spacing: 8) {
                            Button(action: {
                                if playbackViewModel.isPlaying {
                                    playbackViewModel.stopAudio()
                                } else {
                                    playbackViewModel.playAudio(data: audioData)
                                }
                            }) {
                                Image(systemName: playbackViewModel.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(message.isFromUser ? .blue : .gray)
                            }
                            
                            if playbackViewModel.isPlaying {
                                ProgressView(value: playbackViewModel.progress)
                                    .frame(width: 80)
                            }
                        }
                        .padding(.leading, 16)
                    }
                }
                .padding(.horizontal, 8)
                
                if !message.isFromUser {
                    Spacer()
                }
            }
            
            if let error = playbackViewModel.errorMessage {
                Text(error)
                    .font(.caption2)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
        }
    }
}
