//
//  ArtworkList.swift
//  Mixed-Ability-Artwork
//
//  Created by Ritesh Kanchi on 7/22/24.
//

import SwiftUI

struct ArtworkList: View {
    
    @Binding var artworks: [ImageDescription]
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                ForEach(artworks, id: \.id) { imageDesc in
                    ArtworkListItem(imageDescription: imageDesc)
                }
            }
            .padding(.horizontal)
            .padding(.top, 92)
        }
    }
}

#Preview {
    ArtworkList(artworks: .constant(samples))
}
