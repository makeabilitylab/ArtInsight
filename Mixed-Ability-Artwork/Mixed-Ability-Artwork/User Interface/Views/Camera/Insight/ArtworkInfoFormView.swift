//
//  ArtworkInfoFormView.swift
//  Mixed-Ability-Artwork
//
//  Created by Ritesh Kanchi on 7/26/24.
//

import SwiftUI

struct ArtworkInfoFormView: View {
    
    @Binding var artworkName: String
    @Binding var artworkArtist: String
    @Binding var artworkDate: Date
    
    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: 50) {
                Text("Name")
                    .frame(width: 50, alignment: .leading)
                TextField("Artwork name", text: $artworkName, prompt: Text("What is the artwork called?"))
                    .accessibilityHint("Add the name of the artwork here")
            }
            
            HStack(spacing: 50) {
                Text("Artist")
                    .frame(width: 50, alignment: .leading)
                TextField("Artist", text: $artworkArtist, prompt: Text("Who made the artwork?"))
                    .accessibilityHint("Add the name of the artist here")
            }
            
            DatePicker(selection: $artworkDate, label: { Text("Date") })
                .accessibilityHint("When was the artwork made?e")
        }
        .environment(\.colorScheme, .dark)
    }
}


#Preview {
    ArtworkInfoFormView(artworkName: .constant(""), artworkArtist: .constant(""), artworkDate: .constant(Date()))
        .background(.black)
}
