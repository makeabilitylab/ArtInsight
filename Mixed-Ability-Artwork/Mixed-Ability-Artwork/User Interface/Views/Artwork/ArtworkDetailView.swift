//
//  ArtworkDetailView.swift
//  Mixed-Ability-Artwork
//
//  Created by Ritesh Kanchi on 7/22/24.
//

import SwiftUI

struct ArtworkDetailView: View {
    
    @State private var sheetPresent = false
    
    @Environment(\.dismiss) var dismiss
    
    @State private var imageDescription: ImageDescription
    @State private var name: String
    @State private var isAlertPresented = false
    
    @StateObject private var audioRecorder = AudioRecorder()
    @StateObject private var audioPlayer = AudioPlayer()
    
    @State private var currentDescriptive: String
    @State private var currentCreative: String
    @State private var currentQuestions: String
    
    @State private var loadingNewDescription = false
    @State private var loadingNewQuestions = false
    
    @State private var regenerating = false
    @State private var usingRecording = false
    
    var showSave: Bool
    
    init(imageDescription: ImageDescription, showSave: Bool) {
        _imageDescription = .init(initialValue: imageDescription)
        _name = .init(initialValue: imageDescription.name!)
        self.showSave = showSave
        
        currentDescriptive = imageDescription.descriptiveDescription
        currentCreative = imageDescription.creativeDescription
        currentQuestions = imageDescription.questions
    }
    
    var body: some View {
        VStack {
            ArtworkNavbar(imageDescription: $imageDescription, name: $name, isAlertPresented: $isAlertPresented, sheetPresent: $sheetPresent, currentDescriptive: $currentDescriptive, currentCreative: $currentCreative, currentQuestions: $currentQuestions, loadingNewDescription: $loadingNewDescription, loadingNewQuestions: $loadingNewQuestions, regenerating: $regenerating, usingRecording: $usingRecording, showSave: showSave)
                .toolbarColorScheme(.dark)
            ArtworkImage(loadingNewDescription: $loadingNewDescription, image: imageDescription.image)
            Spacer()
        }
        .onAppear(perform: {
            sheetPresent = true
        })
        .background(.black)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $sheetPresent) {
            ArtworkBottomSheet(isAlertPresented: $isAlertPresented, imageDescription: $imageDescription, name: $name, currentDescriptive: $currentDescriptive, currentCreative: $currentCreative, currentQuestions: $currentQuestions, loadingNewDescription: $loadingNewDescription, loadingNewQuestions: $loadingNewQuestions, regenerating: $regenerating, usingRecording: $usingRecording)
                .onDisappear { dismiss() }
        }
    }
}

#Preview {
    ArtworkDetailView(imageDescription: ImageDescription(id: "Image-1", uiImage: UIImage(named: "Placeholder")!, descriptiveDescription: "Description 1", creativeDescription: "creative 1", questions: "", name: "This is a sample name"), showSave: true)
}
