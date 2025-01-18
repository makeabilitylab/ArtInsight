//
//  LibraryView.swift
//  Mixed-Ability-Artwork
//
//  Created by Ritesh Kanchi on 7/22/24.
//

import SwiftUI


struct LibraryView: View {
    
    @State private var searchText = ""
    @State private var searchToggled = false
    
    @Binding var selectedTab: Int
    @Binding var artworks: [ImageDescription]
    
    var body: some View {
        ZStack {
            if searchToggled {
                SearchView(searchText: $searchText, searchToggled: $searchToggled, artworks: $artworks)
            } else {
                ArtworkList(artworks: $artworks)
            }
            LibraryNavbar(searchText: $searchText, searchToggled: $searchToggled, selectedTab: $selectedTab, count: artworks.count)
        }
        .refreshable {
            self.refreshArtworks()
        }
        .onAppear(perform: {
            self.refreshArtworks()
        })
    }
    
    private func refreshArtworks() {
        artworks = ImageManager.shared.getAllImageDescriptions()
    }
}

#Preview {
    TabInterfaceView()
        .environment(\.colorScheme, .dark)
}


struct LibraryNavbar: View {
    
    // TODO: Update to fix focus system
    
    @Binding var searchText: String
    @Binding var searchToggled: Bool
    @Binding var selectedTab: Int
    
    var count: Int
    
    var body: some View {
        VStack {
            VStack(spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(searchToggled ? "Search" : "Library")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .accessibilityAddTraits(.isHeader)
                        Text("\(count) artwork\(count == 1 ? "" : "s")")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if searchToggled {
                        Button("Done") {
                            withAnimation {
                                searchToggled = false
                            }
                        }
                        .fontWeight(.medium)
                        .foregroundStyle(.accent)
                    } else {
                        Button(action: {
                            withAnimation {
                                selectedTab = 1
                                searchText = ""
                            }
                        }) {
                            Label("Capture", systemImage: "camera.fill")
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .background(.regularMaterial, in: Capsule())
                        .buttonStyle(PlainButtonStyle())
                        
                    }
                }
//                SearchBar(searchText: $searchText, searchToggled: $searchToggled)
            }
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [.black, .black, .clear]), startPoint: .top, endPoint: .bottom))
            Spacer()
                .onDisappear {
                    searchToggled = false
                }
        }
      
    }
}

struct SearchBar: View {
    
    @Binding var searchText: String
    @Binding var searchToggled: Bool
    
    var body: some View {
        HStack {
            TextField("", text: $searchText, prompt: Text("Search your library...").foregroundStyle(.white.opacity(0.25)))
                .padding(10)
                .padding(.leading, 24)
                .foregroundStyle(.white)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                    })
                .onTapGesture {
                    withAnimation {
                        searchToggled = true
                    }
                }
            
        }
    }
}
