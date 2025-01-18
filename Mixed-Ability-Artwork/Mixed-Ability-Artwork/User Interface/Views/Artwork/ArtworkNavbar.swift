//
//  ArtworkNavbar.swift
//  Mixed-Ability-Artwork
//
//  Created by Ritesh Kanchi on 8/5/24.
//

import SwiftUI


struct ArtworkNavbar: View {
    
    @Environment(\.dismiss) var dismiss
    
    
    
    @Binding var imageDescription: ImageDescription
    @Binding var name: String
    @Binding var isAlertPresented: Bool
    @Binding var sheetPresent: Bool
    
    @Binding var currentDescriptive: String
    @Binding var currentCreative: String
    @Binding var currentQuestions: String
    
    @Binding var loadingNewDescription: Bool
    @Binding var loadingNewQuestions: Bool
    @Binding var regenerating: Bool
    
    @Binding var usingRecording: Bool
    
    @FocusState var isFocused: Bool
    
    var showSave: Bool
    
    
    var body: some View {
        HStack(alignment: .center) {
            Button(action: {
                sheetPresent = false
                done()
                dismiss()
            }) {
                Image(systemName: "chevron.left.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white)
                    .font(.title)
            }
            .accessibilityLabel("Close \(imageDescription.name ?? "") Artwork")
            .disabled(loadingNewQuestions || loadingNewQuestions)
            .opacity(loadingNewQuestions || loadingNewQuestions ? 0.5 : 1)
            Spacer()
            
            VStack(alignment: .center, spacing: 2) {
                HStack {
                    if loadingNewQuestions || loadingNewDescription {
                        ProgressView()
                            .progressViewStyle(.circular)
                        
                    }
                    Text(
                        loadingNewQuestions && loadingNewDescription ? "Regenerating..." : loadingNewDescription ? "Updating..." : name.replacingOccurrences(of: "-", with: " "))
                    .font(imageDescription.author != nil && !imageDescription.author!.isEmpty ? .subheadline : .headline)
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                    .accessibilityAddTraits(.isHeader)
                }
                if imageDescription.author != nil && !loadingNewQuestions && !loadingNewDescription {
                    if !imageDescription.author!.isEmpty {
                        Text(imageDescription.author!)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .fontWeight(.medium)
                    }
                }
            }
            Spacer()
            Menu {
                if showSave {
                    Button(action: {
                        done()
                    }) {
                        Label("Save Artwork", systemImage: "square.and.arrow.down")
                    }
                    .disabled(loadingNewQuestions || loadingNewQuestions)
                }
                
                Button(action: {
                    withAnimation {
                        regenerating = true
                        loadingNewDescription = true
                        loadingNewQuestions = true
                        addMessage(threadId: imageDescription.id)
                    }
                }) {
                    Label(regenerating ? "Regenerating..." : "Regenerate Content", systemImage: "arrow.triangle.2.circlepath")
                }
                .disabled(loadingNewQuestions || loadingNewQuestions)
                Button(action: {
                    isAlertPresented = true
                }) {
                    Label("Delete Artwork", systemImage: "trash")
                }
                .disabled(loadingNewQuestions || loadingNewQuestions)
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white)
                    .font(.title)
            }
            .accessibilityLabel("Options Menu")
            
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 2)
        .background(LinearGradient(colors: [.black, .black, .clear], startPoint: .top, endPoint: .bottom))
    }
    
    private func done() {
        ImageManager.shared.createDirIfNeeded(for: imageDescription.id)
        ImageManager.shared.save(item: imageDescription)
    }
    
    private func addMessage(threadId: String) {
        OpenAIHelpers.shared.addMessage(threadId: threadId, message: "I'm not satisifed with your description. Redescribe this artwork") {
            runThread(threadId: threadId)
        } failure: { error in
            print("Failed to add message: \(error.localizedDescription)")
        }
    }
    
    private func runThread(threadId: String) {
        OpenAIHelpers.shared.runThread(threadId: threadId) { runId in
            OpenAIHelpers.shared.pollForResult(threadId: threadId, runId: runId, messages: { _ in
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
            requestCompleted(description: message)
        } failure: { error in
            print("Failed to get messages: \(error.localizedDescription)")
        }
    }
    
    private func requestCompleted(description: String) {
        withAnimation {
            // Print the raw response for debugging
            //print("Raw response: \(description)")
            
            print("NEW DESCRIPTION")
            print(description)
            
            // Split the description into components
            let components = description.components(separatedBy: "%%%")
            guard components.count == 4 else {
                fatalError("Description content format is incorrect.")
            }
            
            // Extract and format each component
            name = components[0].replacingOccurrences(of: "Title: ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            currentDescriptive = components[1].replacingOccurrences(of: "Descriptive Description: ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            currentCreative = components[2].replacingOccurrences(of: "Creative Description: ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            currentQuestions = components[3].trimmingCharacters(in: .whitespacesAndNewlines)
            
            // TODO: How to replace all info with new data?
            imageDescription.name = name
            imageDescription.descriptiveDescription = currentDescriptive
            imageDescription.creativeDescription = currentCreative
            imageDescription.questions = currentQuestions
            ImageManager.shared.save(item: imageDescription)
            
            loadingNewDescription = false
            loadingNewQuestions = false
            regenerating = false
            usingRecording = false
        }
    }
}


#Preview {
    ArtworkDetailView(imageDescription: ImageDescription(id: "Image-1", uiImage: UIImage(named: "Placeholder")!, descriptiveDescription: "Description 1", creativeDescription: "creative 1", questions: "", name: "This is a sample name", author: "Max"), showSave: true)
}
