import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @StateObject private var audioViewModel = AudioRecordingViewModel()
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.messages) { message in
                            MessageBubbleView(message: message)
                        }
                    }
                }
                .onChange(of: viewModel.messages) { _ in
                    if let lastMessage = viewModel.messages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            
            if let errorMessage = audioViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
            
            HStack {
                TextField("メッセージを入力...", text: $viewModel.inputMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(viewModel.isLoading || audioViewModel.isRecording)
                
                Button(action: {
                    if audioViewModel.isRecording {
                        audioViewModel.stopRecording()
                    } else {
                        audioViewModel.startRecording()
                    }
                }) {
                    Image(systemName: audioViewModel.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.title2)
                        .foregroundColor(audioViewModel.isRecording ? .red : .blue)
                }
                .disabled(!audioViewModel.hasPermission)
                
                Button(action: {
                    Task {
                        await viewModel.sendMessage()
                    }
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .disabled(viewModel.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading || audioViewModel.isRecording)
            }
            .padding()
        }
    }
}
