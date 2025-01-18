//
//  ImageInsightView.swift
//  Mixed-Ability-Artwork
//
//  Created by Ritesh Kanchi on 7/26/24.
//

import SwiftUI

struct ImageInsightView: View {
    
    @Binding var animate: Bool
    @Binding var continuedOn: Bool
    @Binding var newImageDescription: ImageDescription?
    
    var image: Image
    
    
    var body: some View {
        ZStack {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .accessibilityAddTraits(.isImage)
            if newImageDescription == nil {
                Rectangle()
                    .fill(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .position(x: 180, y: animate ? 40 : 440)
                    .onAppear {
                        animate = true
                    }
                    .animation(
                        .easeInOut(duration: 2)
                        .repeatForever(autoreverses: true),
                        value: animate
                    )
                    .blur(radius: 20)
                    .blendMode(.overlay)
                    .accessibilityHidden(true)
                    .transition(.opacity)
            }
        }
        .accessibilityAddTraits(.isImage)
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .stroke(Color.white.opacity(0.25), lineWidth: 2)
        )
        .frame(width: 360, height: 480)
        .scaleEffect(continuedOn ? 1 : 0.6)
        .padding(.vertical, continuedOn ? 0 : -80)
        .padding(.horizontal, continuedOn ? 0 : -60)
    }
}

//#Preview {
//    ImageInsightView(animate: .constant(false), continuedOn: .constant(true), image: Image("Placeholder"))
//}
