//
//  NewCameraView.swift
//  Mixed-Ability-Artwork
//
//  Created by Ritesh Kanchi on 7/13/24.
//

import SwiftUI

struct CameraContainerView: View {
    
    @State private var uiImage: UIImage?
    @State private var imageDescription: ImageDescription?
    
    @Binding var selectedTab: Int
    @Binding var artworks: [ImageDescription]
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    Text("Capture")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                    NavigationLink(destination: AITestingView()) {
                        Label("Main".uppercased(), systemImage: "checkmark.seal.fill")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(.black)
                            .padding(6)
                            .background(.yellow)
                            .clipShape(.rect(cornerRadius: 8, style: .continuous))
                    }
                    .accessibilityHidden(true)
                }
                .padding()
                .background(.black)
                .foregroundStyle(.white)
                
                CameraView(didCapturePhoto: { uiImage in
                    self.uiImage = uiImage
                }, selectedTab: $selectedTab, artworks: $artworks)
            }
        }
        .fullScreenCover(item: $uiImage) { uiImage in
            PhotoInsightView(uiImage: uiImage) { imageDescription in
                self.uiImage = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.imageDescription = imageDescription
                    selectedTab = 0
                }
            }
        }
        .navigationDestination(item: $imageDescription) { imageDescription in
            ArtworkDetailView(imageDescription:imageDescription, showSave: true)
                .onAppear {
                    withAnimation {
                        selectedTab = 0
                    }
                }
        }
    }
}

#Preview {
    TabInterfaceView()
}


