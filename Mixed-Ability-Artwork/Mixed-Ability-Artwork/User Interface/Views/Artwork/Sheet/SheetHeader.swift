//
//  SheetHeader.swift
//  Mixed-Ability-Artwork
//
//  Created by Ritesh Kanchi on 7/26/24.
//

import SwiftUI

struct SheetHeader: View {
    
    @Binding var sheetTab: Int
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 5) {
                ForEach(buttons, id:\.index) { button in
                    ButtonTabItemView(button: button, active: sheetTab == button.index, sheetTab: $sheetTab)
                }
            }
            .padding([.bottom, .horizontal])
            .background(Color(uiColor: .systemBackground))
            .accessibilityLabel("Artwork Details")
            Divider()
            Spacer()
        }
    }
}

#Preview {
    SheetHeader(sheetTab: .constant(0))
}


struct ButtonTabItemView: View {
    
    var button: ButtonVals
    var active: Bool = false
    @Binding var sheetTab: Int
    
    var body: some View {
        Button(action: {
            withAnimation {
                sheetTab = button.index
            }
        }) {
            HStack {
                Spacer()
                Image(systemName: active ? button.iconFill : button.icon)
                
                if active {
                    Text(button.text)
                        .fixedSize(horizontal: true, vertical: true)
                }
                Spacer()
            }
            .accessibilityHidden(true)
            .buttonStyle(.plain)
            .frame(minWidth: active ? 140 : 70)
            .frame(height: 50)
            .frame(maxWidth: active ? .infinity : 70)
            .padding(.horizontal, active ? 10 : 0)
            .foregroundStyle(active ? button.foreColor : .white)
            .fontWeight(.semibold)
            .background(active ? button.bgColor : Color(uiColor: .secondarySystemFill))
            .clipShape(.rect(cornerRadius: 20, style: .continuous))
            
        }
        .accessibilityLabel(button.text)
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(active ? .isSelected : [])
        .accessibilityValue("\(button.index + 1) of \(buttons.count)")
    }
}
