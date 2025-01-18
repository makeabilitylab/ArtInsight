//
//  ArtworkListItem.swift
//  Mixed-Ability-Artwork
//
//  Created by Ritesh Kanchi on 7/22/24.
//

import SwiftUI

struct ArtworkListItem: View {
    
    @State private var showArtwork: Bool = false
    var imageDescription: ImageDescription
    
    var body: some View {
        NavigationLink(destination:ArtworkDetailView(imageDescription: imageDescription, showSave: false) ) {
            HStack(spacing: 10) {
                imageDescription.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 80)
                    .clipShape(.rect(cornerRadius: 4, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    }
                    .accessibilityLabel("An image titled \(imageDescription.name!)")
                VStack(alignment: .leading, spacing: 5) {
                    Text(String(imageDescription.name!).replacingOccurrences(of: "-", with: " "))
                        .font(.headline)
                    Text((imageDescription.dateTaken ?? Date()).formatted(date: .long, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fontWeight(.medium)
            }
        }
        .accessibilityLabel("Open \(imageDescription.name!) Artwork")
    }
}

#Preview {
    ArtworkListItem(imageDescription: ImageDescription(id: "Image-1", uiImage: UIImage(named: "Placeholder")!, descriptiveDescription: "Description 1", creativeDescription: "creative", questions: ""))
}
