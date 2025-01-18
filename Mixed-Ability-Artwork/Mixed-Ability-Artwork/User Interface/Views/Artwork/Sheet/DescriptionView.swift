//
//  DescriptionView.swift
//  Mixed-Ability-Artwork
//
//  Created by Ritesh Kanchi on 7/22/24.
//

import SwiftUI


struct DescriptionView: View {
    
    @State private var descriptionTab = 0
    
    @Binding var loadingNewDescription: Bool
    @Binding var currentDescriptive: String
    @Binding var currentCreative: String
    
    var imageDescription: ImageDescription
    
    let pasteboard = UIPasteboard.general
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Picker("Description options", selection: $descriptionTab) {
                Text("Descriptive").tag(0)
                Text("Creative").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            Text(descriptionTab == 0 ? currentDescriptive : currentCreative)
                .redacted(reason: loadingNewDescription ?  .placeholder : [])
                .lineSpacing(10)
                .padding(.top, 5)
            Button(action: {
                withAnimation {
                    if descriptionTab == 0 {
                        pasteboard.string = currentDescriptive
                    } else {
                        pasteboard.string = currentCreative
                    }
                }
            }) {
                Label("Copy \(descriptionTab == 0 ? "Descriptive" : "Creative") Description", systemImage: "doc.on.doc")
            }
            .buttonStyle(SmallButtonStyle())
            .frame(maxWidth: .infinity, alignment: .center)
            .disabled(loadingNewDescription)
            .opacity(loadingNewDescription ? 0.5 : 1)
            .padding(.top)
            
        }
        .padding(.horizontal)
        .padding(5)
    }
}


