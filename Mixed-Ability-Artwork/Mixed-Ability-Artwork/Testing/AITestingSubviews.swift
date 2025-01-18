//
//  AITestingSubviews.swift
//  Mixed-Ability-Artwork
//
//  Created by Ritesh Kanchi on 8/8/24.
//

import SwiftUI

struct ListItem: View {
    
    var title: String
    var text: String
    var error: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            HStack(spacing: 5) {
                if text.isEmpty || error || text == "No" {
                    Image(systemName: error ? "exclamationmark.octagon.fill" : "exclamationmark.triangle.fill")
                        .foregroundStyle(error ? .red : .yellow)
                }
                Text(title)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
            Text(text.isEmpty ? "None" : text)
                .multilineTextAlignment(.trailing)
                .foregroundStyle(text.isEmpty ? .secondary : .primary)
        }
        
    }
}

struct TestDetailView: View {
    var title: String
    var content: String
    
    var body: some View {
        ScrollView() {
            Text(content)
                .padding()
                .multilineTextAlignment(.leading)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
