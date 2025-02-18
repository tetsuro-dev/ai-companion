import SwiftUI

struct ChatView: View {
    @StateObject private var audioPlaybackViewModel = AudioPlaybackViewModel()
    @StateObject private var audioViewModel = AudioRecordingViewModel()
    @StateObject private var viewModel: ChatViewModel
    
    init() {
        let playbackVM = AudioPlaybackViewModel()
        _viewModel = StateObject(wrappedValue: ChatViewModel(audioPlaybackViewModel: playbackVM))
    }
    
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
            
            if let recognizedText = audioViewModel.recognitionViewModel.recognizedText,
               !recognizedText.isEmpty {
                Text(recognizedText)
                    .foregroundColor(.gray)
                    .font(.body)
                    .padding(.horizontal)
            }
            
            HStack {
                if audioPlaybackViewModel.isPlaying {
                    Button(action: {
                        audioPlaybackViewModel.stopPlayback()
                    }) {
                        Image(systemName: "stop.circle.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                }
                
                TextField("メッセージを入力...", text: $viewModel.inputMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(viewModel.isLoading || audioViewModel.isRecording || audioPlaybackViewModel.isPlaying)
                
                Button(action: {
                    if audioViewModel.isRecording {
                        audioViewModel.stopRecording()
                    } else {
                        if audioPlaybackViewModel.isPlaying {
                            audioPlaybackViewModel.stopPlayback()
                        }
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
