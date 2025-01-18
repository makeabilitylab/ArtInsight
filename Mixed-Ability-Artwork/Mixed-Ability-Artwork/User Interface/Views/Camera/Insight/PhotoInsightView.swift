//
//  PhotoInsightView.swift
//  Mixed-Ability-Artwork
//
//  Created by Ritesh Kanchi on 7/23/24.
//

import SwiftUI

struct PhotoInsightView: View {
    
    typealias Completion = (ImageDescription) -> Void
    
    // MARK: Properties
    
    @Environment(\.dismiss) var dismiss
    
    @State private var isAlertPresented = false
    
    // MARK: User-inputted Properties
    @State private var artworkName: String = ""
    @State private var artworkArtist: String = ""
    @State private var artworkDate: Date = Date()
    
    @State private var addedArtworkInfo = false
    @State private var continuedOn = false
    @State private var progress = 0
    
    @State private var loading = false
    @State private var messageAdded = false
    @State private var threadID = ""
    @State private var imageID = ""
    @State private var runID = ""
    
    @State private var animate = false
    
    @State private var newImageDescription: ImageDescription? = nil
    
    let uiImage: UIImage
    let completion: Completion?
    
    init(uiImage: UIImage, completion: Completion? = nil) {
        self.uiImage = uiImage
        self.completion = completion
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 20) {
                Spacer()
                ImageInsightView(animate: $animate, continuedOn: $continuedOn, newImageDescription: $newImageDescription, image: Image(uiImage: uiImage))
                if !continuedOn {
                    VStack(alignment: .center, spacing: 10) {
                        Text("Add artwork info")
                            .font(.title)
                            .fontWeight(.semibold)
                        Text("If you don’t add a name, one will be automatically generated for you.")
                            .multilineTextAlignment(.center)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    ArtworkInfoFormView(artworkName: $artworkName, artworkArtist: $artworkArtist, artworkDate: $artworkDate)
                    
                } else {
                    VStack {
                        Text(addedArtworkInfo ? artworkName : newImageDescription == nil ? "Artwork" : newImageDescription!.name!.replacingOccurrences(of: "-", with: " "))
                            .font(.title)
                            .fontWeight(.semibold)
                            .transition(.identity)
                        if !artworkArtist.isEmpty {
                            Text("By \(artworkArtist)")
                                .font(.headline)
                        }
                    }
                }
                Spacer()
                buttons
            }
            .padding(.horizontal)
            
            toolbar
        }
        .background(.black)
        .onAppear { sendRequest() }
        .onDisappear() { dismiss() }
        .alert(isPresented: $isAlertPresented, content: { alert })
        .environment(\.colorScheme, .dark)
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.5), trigger: newImageDescription != nil)
    }
    
    @ViewBuilder
    private var toolbar: some View {
        VStack {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundStyle(.white)
                .disabled(newImageDescription != nil)
                .opacity(newImageDescription != nil ? 0.5 : 1)
                Spacer()
                HStack(spacing: 5) {
                    if newImageDescription != nil {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .imageScale(.small)
                    } else {
                        ProgressView(value: 0.5)  .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .controlSize(.small)
                    }
                    Text(newImageDescription != nil ? "Image Analyzed!" : "Analyzing Image")
                }
                .font(.caption)
                .fontWeight(.semibold)
                .padding(8)
                .background(.ultraThinMaterial)
                .clipShape(.capsule)
                .accessibility(addTraits: [.updatesFrequently])
                .accessibilityLabel(progress < 100 ? "Image \(progress) percent analyzed" : "Image Analyzed")
            }
            .padding(10)
            .background(LinearGradient(colors: [.black, .black.opacity(0.5), .clear], startPoint: .top, endPoint: .bottom))
            Spacer()
        }
    }
    
    @ViewBuilder
    private var buttons: some View {
        VStack(spacing: 10) {
            if !continuedOn {
                Button("Save info") {
                    withAnimation {
                        if !artworkName.isEmpty || !artworkArtist.isEmpty {
                            addedArtworkInfo = true
                        } else {
                            addedArtworkInfo = false
                        }
                        
                        continuedOn = true
                        
                        finishInsight()
                    }
                }
                .buttonStyle(FullWidthWhiteButtonStyle())
            }
            if newImageDescription == nil || !continuedOn {
                Button("\(continuedOn ? "Edit" : "Skip") artwork information") {
                    withAnimation {
                        continuedOn.toggle()
                        
                        finishInsight()
                    }
                }
                .buttonStyle(FullWidthGlassButtonStyle())
            }
        }
    }
    
    private var dismissButton: Alert.Button {
        let label = Text("Dismiss")
        return Alert.Button.default(label) {
            //requestCompleted(description: "Failed to generate description")
            dismiss()
        }
    }
    
    private func finishInsight() {
        withAnimation {
            if continuedOn {
                if addedArtworkInfo && !artworkName.isEmpty {
                    newImageDescription?.name = artworkName
                }
            }
            
            if continuedOn && newImageDescription != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    completion?(newImageDescription!)
                }
            }
        }
    }
    
    private var alert: Alert {
        let title = Text("Oops! Something went wrong")
        let message = Text("Try again later")
        
        return Alert(title: title, message: message, dismissButton: dismissButton)
    }
    
    private func sendRequest(){
        createThread { success in
            guard success else { return }
            self.uploadImage(uiImage: self.uiImage) { success in
                guard success else { return }
                self.addMessage(threadId: self.threadID, imageId: self.imageID, userMessage: "Describe this artwork") { success in
                    guard success else { return }
                    self.runThread(threadId: self.threadID)
                }
            }
        }
    }
    
    private func createThread(completion: @escaping (Bool) -> Void) {
        loading = true
        progress = 10
        OpenAIHelpers.shared.createThread { threadId in
            loading = false
            threadID = threadId
            completion(true)
        } failure: { error in
            isAlertPresented = true
            print("Failed to create thread: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    private func uploadImage(uiImage: UIImage, completion: @escaping (Bool) -> Void) {
        loading = true
        progress = 20
        OpenAIHelpers.shared.uploadImage(uiImage: uiImage) { imageId in
            loading = false
            imageID = imageId
            completion(true)
        } failure: { error in
            isAlertPresented = true
            print("Failed to upload image: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    private func addMessage(threadId: String, imageId: String = "", userMessage: String, completion: @escaping (Bool) -> Void) {
        messageAdded = false
        loading = true
        progress = 30
        OpenAIHelpers.shared.addMessage(threadId: threadId, message: userMessage, imageId: imageId) {
            messageAdded = true
            loading = false
            completion(true)
        } failure: { error in
            isAlertPresented = true
            print("Failed to add message: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    private func runThread(threadId: String) {
        loading = true
        progress = 50
        OpenAIHelpers.shared.runThread(threadId: threadId) { runId in
            runID = runId
            OpenAIHelpers.shared.pollForResult(threadId: threadId, runId: runId, messages: { _ in
                progress = 70
                getMessages(threadId: threadId)
            }, failure: { error in
                isAlertPresented = true
                print("Failed to poll for result: \(error.localizedDescription)")
            })
        } failure: { error in
            isAlertPresented = true
            print("Failed to run thread: \(error.localizedDescription)")
        }
    }
    
    private func getMessages(threadId: String) {
        OpenAIHelpers.shared.getMessages(threadId: threadId) { message in
            loading = false
            progress = 90
            self.requestCompleted(description: message)
        } failure: { error in
            isAlertPresented = true
            print("Failed to get messages: \(error.localizedDescription)")
        }
    }
    
    private func requestCompleted(description: String) {
        // Print the raw response for debugging
        //print("Raw response: \(description)")
        
        // Split the description into components
        let components = description.components(separatedBy: "%%%")
        guard components.count == 4 else {
            fatalError("Description content format is incorrect.")
        }
        
        // Extract and format each component
        let title = components[0].replacingOccurrences(of: "Title: ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        let descriptiveDescription = components[1].replacingOccurrences(of: "Descriptive Description: ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        let creativeDescription = components[2].replacingOccurrences(of: "Creative Description: ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        let questions = components[3].replacingOccurrences(of: "Questions:", with: "").trimmingCharacters(in: .whitespaces)
        
        withAnimation {
            // Create an ImageDescription instance
            
            let result = ImageDescription(
                id: threadID, // Use the title as the ID
                uiImage: uiImage,
                descriptiveDescription: descriptiveDescription,
                creativeDescription: creativeDescription,
                questions: questions,
                name: title,
                author: artworkArtist,
                dateTaken: artworkDate
            )
            
            newImageDescription = result
            
        }
        
        progress = 100
        
        // Call the completion handler with the result
        finishInsight()
        
    }
}

#Preview {
    PhotoInsightView(uiImage: UIImage(named: "Placeholder")!)
}
