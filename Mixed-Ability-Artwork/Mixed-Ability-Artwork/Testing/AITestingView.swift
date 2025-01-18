//
//  AITestingView.swift
//  Mixed-Ability-Artwork
//
//  Created by Ritesh Kanchi on 8/7/24.
//

import SwiftUI


struct AITestingView: View {
    
    @State private var threadID = ""
    @State private var imageID = ""
    @State private var runID = ""
    
    @State private var message = "Describe this artwork my child made."
    @State private var transcript = transSample
    
    @State private var loading = false
    @State private var messageAdded = false
    
    @State private var description = ""
    @State private var pastDescription = ""
    
    @State private var runProgress = 0.0
    
    
    @FocusState private var isFocusedOnText: Bool
    
    var body: some View {
        List {
            Section(header: Text("Create thread")) {
                Button("Create new thread") {
                    createThread()
                }
                .disabled(!threadID.isEmpty)
                ListItem(title: "Thread ID", text: threadID)
            }
            
            Section(header: Text("Upload Image")) {
                Button("Upload image to thread") {
                    uploadImage(uiImage: UIImage(named: "Placeholder")!)
                }
                .disabled(threadID.isEmpty || !imageID.isEmpty)
                NavigationLink(destination: Image("Placeholder").resizable().aspectRatio(contentMode: .fit).navigationTitle("Sample image").navigationBarTitleDisplayMode(.inline)) {
                    Text("Sample image")
                }
                ListItem(title: "Image ID", text: imageID, error: threadID.isEmpty)
            }
            
            Section(header: Text("Add message"), footer: Text("You can edit the message that is sent to the assistant.")) {
                TextField("Message", text: $message)
                    .focused($isFocusedOnText)
                Button("Add message") {
                    addMessage(threadId: threadID, imageId: imageID, userMessage: message)
                }
                .disabled(threadID.isEmpty || imageID.isEmpty || message.isEmpty)
                ListItem(title: "Added?", text: messageAdded ? "Yes" : "No", error: threadID.isEmpty || imageID.isEmpty)
                NavigationLink(destination: TestDetailView(title: "Generated response", content: pastDescription.isEmpty ? description : pastDescription)) {
                    Text("Generated response \(pastDescription.isEmpty ? "" : "(past)")")
                }
                .disabled((description.isEmpty && pastDescription.isEmpty) || threadID.isEmpty || runID.isEmpty || imageID.isEmpty)
            }
            
            Section(header: Text("Run Thread")) {
                Button("Run thread") {
                    withAnimation {
                        print("START RUN")
                        runThread(threadId: threadID)
                    }
                }
                .disabled(threadID.isEmpty || imageID.isEmpty || !messageAdded)
                ListItem(title: "Run ID", text: runID, error: threadID.isEmpty || imageID.isEmpty)
                ProgressView(value: runProgress)
            }
            
            
            Section(header: Text("Update"), footer: Text("You can edit the \"transcript\" provided.")) {
                TextEditor(text: $transcript)
                    .focused($isFocusedOnText)
                Button("Add transcript message") {
                    pastDescription = description
                    description = ""
                    addMessage(threadId: threadID, userMessage: transcriptionPrompt + transcript)
                }
                .disabled(description.isEmpty || threadID.isEmpty || imageID.isEmpty || runID.isEmpty)
                Button("Run new thread") {
                    withAnimation {
                        runThread(threadId: threadID)
                    }
                }
                .disabled(!description.isEmpty || threadID.isEmpty || imageID.isEmpty || runID.isEmpty)
                NavigationLink(destination: TestDetailView(title: "Updated response", content: description)) {
                    Text("Updated response")
                }
                .disabled(description.isEmpty || pastDescription.isEmpty || threadID.isEmpty || runID.isEmpty || imageID.isEmpty)
                ProgressView(value: runProgress)
            }
            
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Testbench")
        .toolbar {
            if isFocusedOnText {
                Button("Close Keyboard") {
                    isFocusedOnText = false
                }
            } else {
                if loading {
                    ProgressView(value: 0.5)
                        .progressViewStyle(.circular)
                } else {
                    HStack(spacing: 5) {
                        Image(systemName: "wrench.and.screwdriver.fill")
                        Text("Testing".uppercased())
                    }
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.black)
                    .padding(6)
                    .background(Color(uiColor: .cyan))
                    .clipShape(.rect(cornerRadius: 8, style: .continuous))
                    .accessibilityHidden(true)
                }
            }
        }
    }
    
    private func createThread() {
        loading = true
        OpenAIHelpers.shared.createThread { threadId in
            loading = false
            threadID = threadId
        } failure: { error in
            print("Failed to create thread: \(error.localizedDescription)")
        }
    }
    
    private func uploadImage(uiImage: UIImage) {
        loading = true
        OpenAIHelpers.shared.uploadImage(uiImage: uiImage) { imageId in
            loading = false
            imageID = imageId
        } failure: { error in
            print("Failed to upload image: \(error.localizedDescription)")
        }
    }
    
    private func addMessage(threadId: String, imageId: String = "", userMessage: String) {
        messageAdded = false
        loading = true
        OpenAIHelpers.shared.addMessage(threadId: threadId, message: userMessage, imageId: imageId) {
            messageAdded = true
            loading = false
        } failure: { error in
            print("Failed to add message: \(error.localizedDescription)")
        }
    }
    
    private func runThread(threadId: String) {
        runProgress = 0.0
        loading = true
        OpenAIHelpers.shared.runThread(threadId: threadId) { runId in
            runID = runId
            runProgress = 0.5
            OpenAIHelpers.shared.pollForResult(threadId: threadId, runId: runId, messages: { _ in
                runProgress = 0.75
                getMessages(threadId: threadId)
            }, failure: { error in
                print("Failed to poll for result: \(error.localizedDescription)")
            })
        } failure: { error in
            print("Failed to run thread: \(error.localizedDescription)")
        }
    }
    
    private func getMessages(threadId: String) {
        OpenAIHelpers.shared.getMessages(threadId: threadId) { message in
            loading = false
            description = message
            runProgress = 1.0
        } failure: { error in
            print("Failed to get messages: \(error.localizedDescription)")
        }
    }
    
}


#Preview {
    AITestingView()
}
