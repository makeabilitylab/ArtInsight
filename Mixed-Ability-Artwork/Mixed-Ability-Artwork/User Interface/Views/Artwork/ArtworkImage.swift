//
//  ArtworkImage.swift
//  Mixed-Ability-Artwork
//
//  Created by Ritesh Kanchi on 8/10/24.
//

import SwiftUI

struct ArtworkImage: View {
    
    @State var animate: Bool = false
    @Binding var loadingNewDescription: Bool
    
    var image: Image
    
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.width * 4 / 3
    
    var body: some View {
        ZStack {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .accessibilityAddTraits(.isImage)
            if loadingNewDescription {
                Rectangle()
                    .fill(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .position(x: width/2 , y: animate ? 50 : height-50)
                    .onAppear {
                        animate = true
                    }
                    .onDisappear {
                        animate = false
                    }
                    .animation(
                        .easeInOut(duration: 2.5)
                        .repeatForever(autoreverses: true),
                        value: animate
                    )
                    .blur(radius: 25)
                    .blendMode(.overlay)
                    .accessibilityHidden(true)
                    .transition(.opacity)
            }
        }
        .frame(width: width, height: height)
    }
}

#Preview {
    ZStack {
        VStack {
            Spacer()
            ArtworkImage(loadingNewDescription: .constant(true), image: Image("Placeholder"))
            Spacer()
        }
        VStack {
            Text("Width: \(UIScreen.main.bounds.width)")
            Text("Height: \(UIScreen.main.bounds.width * 4 / 3)")
            Spacer()
        }
    }
    .foregroundStyle(.white)
    .background(.black)
}
