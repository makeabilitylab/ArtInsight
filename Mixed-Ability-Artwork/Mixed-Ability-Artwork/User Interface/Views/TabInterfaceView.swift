//
//  TabInterfaceView.swift
//  Mixed-Ability-Artwork
//
//  Created by Ritesh Kanchi on 7/23/24.
//

import SwiftUI

struct TabInterfaceView: View {
    
    @State private var selectedTab = 1
    @State private var artworks: [ImageDescription]
    
    init() {
        artworks = ImageManager.shared.getAllImageDescriptions()
    }
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                LibraryView(selectedTab: $selectedTab, artworks: $artworks)
                    .tag(0)
                    .navigationBarHidden(true)
                    .navigationTitle("Library")
                CameraContainerView(selectedTab: $selectedTab, artworks: $artworks)
                    .tag(1)
                    .navigationBarHidden(true)
                    .navigationTitle("Capture")
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea(.all)
            .background(.black)
            .foregroundStyle(.white)
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    TabInterfaceView()
}
