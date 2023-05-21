import SwiftUI
import OpenAISwift

final class ViewModel: ObservableObject {
    init() {}
    
    private var client: OpenAISwift?
    
    func setup() {
        client = OpenAISwift(authToken: Secret.yourOpenAIAPIKey)
    }
    
    func send(text: String, completion: @escaping (String) -> Void) {
        client?.sendCompletion(with: text, maxTokens: 500) { result in
            switch result {
            case .success(let model):
                let output = model.choices?.first?.text ?? ""
                completion(output)
            case .failure:
                break
            }
        }
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State private var text = ""
    @State private var messages = [Message]()
    
    struct Message: Identifiable, Equatable {
        let id = UUID()
        let sender: String
        let content: String
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        LazyVStack {
                            ForEach(messages) { message in
                                MessageView(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding(.horizontal)
                        .onChange(of: messages) { _ in
                            scrollViewProxy.scrollTo(messages.last?.id, anchor: .bottom)
                        }
                    }
                }
                
                HStack {
                    TextField("Type here...", text: $text)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: send) {
                        Text("Send")
                    }
                    .padding(.trailing)
                }
                .padding(.bottom)
            }
            .navigationBarTitle("Chat")
            .onAppear {
                viewModel.setup()
            }
        }
    }
    
    private func send() {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        let message = Message(sender: "Me", content: text)
        messages.append(message)
        
        viewModel.send(text: text) { answer in
            DispatchQueue.main.async {
                let message = Message(sender: "ChatGPT model", content: answer)
                messages.append(message)
                text = ""
            }
        }
    }
}

struct MessageView: View {
    let message: ContentView.Message
    
    var body: some View {
        HStack {
            if message.sender == "Me" {
                Spacer()
                Text(message.content)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            } else {
                Text(message.content)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
