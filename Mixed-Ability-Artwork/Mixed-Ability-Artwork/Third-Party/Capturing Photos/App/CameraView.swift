/*
 See the License.txt file for this sample’s licensing information.
 */

import SwiftUI
import UIKit

struct CameraView: View {
    
    @StateObject private var model = DataModel()
    
    @Binding var selectedTab: Int
    @Binding var artworks: [ImageDescription]
    
    @State var photoTaken = false
    
    private static let barHeightFactor = 0.15
    private var didCapturePhoto: ((UIImage?) -> ())?
    
    init(didCapturePhoto: ((UIImage?) -> ())? = nil, selectedTab: Binding<Int>, artworks: Binding<[ImageDescription]>) {
        self.didCapturePhoto = didCapturePhoto
        self._selectedTab = selectedTab
        self._artworks = artworks
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ViewfinderView(image: $model.viewfinderImage)
                    .ignoresSafeArea()
                VStack {
                    ZStack {
                        Color.clear
                    }
                    .frame(height: UIScreen.main.bounds.size.width * 4/3)
                    .accessibilityElement()
                    .accessibilityLabel("Camera Viewfinder")
                    .accessibilityAddTraits([.isImage])
                    .border(Color.white.opacity(0.25), width: 1)
                    VStack {
                        Spacer()
                        buttonsView()
                        Spacer()
                    }
                    .background(.black)
                
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .task {
                await model.camera.start()
                await model.loadPhotos()
                await model.loadThumbnail()
            }
        }
        .onAppear() {
            model.camera.didCapturePhoto = didCapturePhoto
        }
    }
    
    private func buttonsView() -> some View {
        HStack(spacing: 0) {
            LibraryButton(selectedTab: $selectedTab, artworks: $artworks)
            Button {
                withAnimation {
                    photoTaken = true
                    model.camera.takePhoto()
                    photoTaken = false
                }
            } label: {
                Label {
                    Text("Take Picture")
                } icon: {
                    ZStack {
                        Circle()
                            .strokeBorder(.white, lineWidth: 3)
                            .frame(width: 62, height: 62)
                        Circle()
                            .fill(.white)
                            .frame(width: 50, height: 50)
                    }
                }
            }
            .sensoryFeedback(.increase, trigger: photoTaken)
            .frame(width: UIScreen.main.bounds.width/3)
            .accessibilityHint(Text("Take a photo of artwork to generate an AI description"))
            HStack {
                Spacer()
                Button(action: {
                    // swap camera or other functionality
                }) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                }
                .buttonStyle(IconButtonStyle())
                .accessibilityHidden(true)
                .hidden()
            }
            .padding(.trailing)
            .frame(width: UIScreen.main.bounds.width/3)
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    CameraView(selectedTab: .constant(1), artworks: .constant([]))
}

struct LibraryButton: View {
    
    @Binding var selectedTab: Int
    @Binding var artworks: [ImageDescription]
    
    var body: some View {
        HStack {
            if artworks.isEmpty {
                Button(action: {
                    withAnimation {
                        selectedTab = 0
                    }
                }) {
                    Image(systemName: "photo.stack.fill")
                }
                .buttonStyle(IconButtonStyle())
                .accessibilityLabel("Artwork Library")
            } else {
                Button(action: {
                    withAnimation {
                        selectedTab = 0
                    }
                }) {
                    ZStack(alignment: .leading) {
                        if artworks.count > 2 {
                            pictureView(image: artworks[2].image)
                                .opacity(0.75)
                                .rotationEffect(Angle(degrees: 30))
                        }
                        if artworks.count > 1 {
                            pictureView(image: artworks[1].image)
                                .opacity(0.75)
                                .rotationEffect(Angle(degrees: 15))
                        }
                        pictureView(image: artworks.first!.image)
                    }
                }
                .accessibilityLabel("Artwork Library")
            }
            
            Spacer()
        }
        .padding(.leading)
        .frame(width: UIScreen.main.bounds.width/3)
    }
    
    private func pictureView(image: Image) -> some View {
        image
            .resizable()
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .frame(width: 44, height: 58)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(.regularMaterial, lineWidth: 1)
            )
    }
}
