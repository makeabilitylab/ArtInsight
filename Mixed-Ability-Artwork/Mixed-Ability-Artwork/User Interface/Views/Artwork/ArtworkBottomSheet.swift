//
//  ArtworkBottomSheet.swift
//  Mixed-Ability-Artwork
//
//  Created by Ritesh Kanchi on 7/26/24.
//

import SwiftUI

struct ArtworkBottomSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var sheetTab = 0

    @State private var selectedDetent: PresentationDetent = .small
    
    @Binding private var isAlertPresented: Bool
    @Binding private var imageDescription: ImageDescription
    @Binding var name: String
    
    @Binding var currentDescriptive: String
    @Binding var currentCreative: String
    @Binding var currentQuestions: String
    
    @Binding var loadingNewDescription: Bool
    @Binding var loadingNewQuestions: Bool
    @Binding var regenerating: Bool
    
    @Binding var usingRecording: Bool
    
    init(isAlertPresented: Binding<Bool>, imageDescription: Binding<ImageDescription>, name: Binding<String>, currentDescriptive: Binding<String>, currentCreative: Binding<String>, currentQuestions: Binding<String>, loadingNewDescription: Binding<Bool>, loadingNewQuestions: Binding<Bool>, regenerating: Binding<Bool>, usingRecording: Binding<Bool>){
        _isAlertPresented = isAlertPresented
        _imageDescription = imageDescription
        _name = name
        _currentDescriptive = currentDescriptive
        _currentCreative = currentCreative
        _currentQuestions = currentQuestions
        _loadingNewDescription = loadingNewDescription
        _loadingNewQuestions = loadingNewQuestions
        _regenerating = regenerating
        _usingRecording = usingRecording
    }
    
    
    var body: some View {
        ZStack {
            TabView(
                selection: Binding<Int>(
                    get: {
                        sheetTab
                    },
                    set: { targetTab in
                        withAnimation {
                            sheetTab = targetTab
                        }
                    }
                ),
                content: {
                    ForEach(0..<buttons.count, id:\.self) { index in
                        ScrollView {
                            Group {
                                switch index {
                                case 1:
                                    RecordingView(name: $name, usingRecording: $usingRecording, sheetTab: $sheetTab, loadingNewDescription: $loadingNewDescription, currentDescriptive: $currentDescriptive, currentCreative: $currentCreative, currentQuestions: $currentQuestions,imageDescription: $imageDescription, regenerating: $regenerating)
                                case 2:
                                    QuestionsView(loadingNewQuestions: $loadingNewQuestions, currentQuestions: $currentQuestions)
                                default:
                                    DescriptionView(loadingNewDescription: $loadingNewDescription, currentDescriptive: $currentDescriptive, currentCreative: $currentCreative, imageDescription: imageDescription)
                                }
                            }
                            .padding(.top, 80)
                            .padding(.bottom, 40)
                        }
                        .tag(index)
                    }
                }
            )
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea(.container)
            Spacer()
            SheetHeader(sheetTab: $sheetTab)
        }
        .presentationDragIndicator(.visible)
        .presentationBackgroundInteraction(.enabled)
        .interactiveDismissDisabled()
        .accessibilityAddTraits(.isModal)
        .padding(.top, 30)
        .foregroundStyle(.white)
        .presentationDetents(detents, selection: $selectedDetent)
        .presentationCornerRadius(20)
        .presentationBackground {
            Color(uiColor: .systemBackground).environment(\.colorScheme, .dark)
        }
        .environment(\.colorScheme, .dark)
        .accessibilityAddTraits(.isModal)
        .onDisappear(perform: {
            withAnimation {
                dismiss()
            }
        })
        .alert(isPresented: $isAlertPresented, content: {
            alert
        })
    }
    
    private var alert: Alert {
        let title = Text("Confirm Deletion")
        let message = Text("Are you sure you want to delete your artwork?")
        
        return Alert(title: title, message: message, primaryButton: keepButton, secondaryButton: discardButton)
    }
    
    private var discardButton: Alert.Button {
        let label = Text("Discard")
        
        return Alert.Button.destructive(label) {
            ImageManager.shared.deleteDirIfExists(for: imageDescription.id)
            dismiss()
        }
    }
    
    private var keepButton: Alert.Button {
        let label = Text("Keep")
        
        return Alert.Button.default(label)
    }
}




#Preview {
    ArtworkDetailView(imageDescription: ImageDescription(id: "Image-1", uiImage: UIImage(named: "Placeholder")!, descriptiveDescription: "Description 1", creativeDescription: "creative 1", questions: ""), showSave: true)
}
