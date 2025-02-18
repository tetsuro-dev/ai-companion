import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Text("AI Companion")
                .font(.largeTitle)
                .padding()
            
            ChatView()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
