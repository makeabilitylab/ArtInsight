//
//  ButtonStyles.swift
//  Mixed-Ability-Artwork
//
//  Created by Ritesh Kanchi on 7/24/24.
//
import SwiftUI

struct IconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .imageScale(.large)
            .foregroundStyle(.white)
            .frame(width: 44, height: 44)
            .background(.regularMaterial)
            .clipShape(Circle())
    }
}

struct FullWidthWhiteButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.medium)
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(.white)
            .foregroundStyle(.black)
            .clipShape(.rect(cornerRadius: 12, style: .continuous))
    }
}

struct FullWidthGlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.medium)
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(.white.opacity(0.1))
            .foregroundStyle(.white)
            .clipShape(.rect(cornerRadius: 12, style: .continuous))
    }
}

struct SmallButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .font(.caption)
            .fontWeight(.medium)
            .background(.regularMaterial, in: Capsule())
            .buttonStyle(PlainButtonStyle())
    }
}

struct SmallMenuButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .imageScale(.small)
//            .padding(10)
            .frame(width: 32, height: 32, alignment: .center)
            .background(.ultraThickMaterial)
            .clipShape(.circle)
            .fontWeight(.medium)
            .foregroundStyle(.white)
    }
}

