import SwiftUI
import AVFoundation
import UIKit
import OpenAISwift

final class ViewModel: ObservableObject {
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
    
    func playMessageReceivedSound() {
        let systemSoundID: SystemSoundID = 1016
        AudioServicesPlaySystemSound(systemSoundID)
    }
    
    func triggerVibration() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

struct ChatView: View {
    @ObservedObject var viewModel = ViewModel()
    @State private var text = ""
    @State private var messages = [Message]()
    @State private var showSettingsSheet = false
    @State private var messageColor = Color.blue
    
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
                                MessageView(message: message, messageColor: messageColor)
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
            .navigationBarItems(trailing: Button(action: showSettings) {
                Text("Settings")
            })
            .onAppear {
                viewModel.setup()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                stopSound()
                stopVibration()
            }
            .sheet(isPresented: $showSettingsSheet) {
                SettingsPanelView(messageColor: $messageColor)
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
                viewModel.playMessageReceivedSound()
                viewModel.triggerVibration()
            }
        }
    }
    
    private func stopSound() {
        AudioServicesDisposeSystemSoundID(1016)
    }
    
    private func stopVibration() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func showSettings() {
        showSettingsSheet = true
    }
}

struct MessageView: View {
    let message: ChatView.Message
    let messageColor: Color
    
    var body: some View {
        HStack {
            if message.sender == "Me" {
                Spacer()
                Text(message.content)
                    .padding()
                    .background(messageColor)
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

struct SettingsPanelView: View {
    @Binding var messageColor: Color
    
    var body: some View {
        VStack {
            ColorPicker("Message Color", selection: $messageColor)
                .padding()
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
