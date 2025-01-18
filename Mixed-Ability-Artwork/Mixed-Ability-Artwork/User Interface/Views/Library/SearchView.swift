//
//  SearchView.swift
//  Mixed-Ability-Artwork
//
//  Created by Ritesh Kanchi on 7/22/24.
//

import SwiftUI

struct SearchView: View {
    
    @Binding var searchText: String
    @Binding var searchToggled: Bool
    @Binding var artworks: [ImageDescription]
    
    var body: some View {
        if searchText.isEmpty {
            VStack(spacing: 20) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 64, weight: .medium))
                    .foregroundStyle(.gray)
                Text("Search by title, date, artist, or keywords from artwork or recordings.")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal,20)
                SearchSuggestions(searchText: $searchText)
            }
        } else {
            ArtworkList(artworks: $artworks)
        }
    }
}

// Creating a wrapping layout is messy...will come back to this later on!
struct SearchSuggestions: View {
    
    @Binding var searchText: String
    
    let items = ["Samantha", "October", "Purple house"]
    
    var body: some View {
        VStack {
            HStack {
                ForEach(items.dropLast(), id: \.self) { text in
                    Button("\"\(text)\"") {
                        searchText = text
                    }
                    .fontWeight(.medium)
                    .foregroundStyle(.accent)
                    .buttonBorderShape(.roundedRectangle)
                    .buttonStyle(BorderedButtonStyle())
                }
            }
            ForEach([items.last!], id: \.self) { text in
                Button("\"\(text)\"") {
                    searchText = text
                }
                .fontWeight(.medium)
                .foregroundStyle(.accent)
                .buttonBorderShape(.roundedRectangle)
                .buttonStyle(BorderedButtonStyle())
            }
        }
    }
    
    
}
