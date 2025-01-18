//
//  QuestionsView.swift
//  Mixed-Ability-Artwork
//
//  Created by Ritesh Kanchi on 7/22/24.
//

import SwiftUI


struct QuestionsView: View {
    
    @Binding var loadingNewQuestions: Bool
    @Binding var currentQuestions: String
    
    var qlist: [String]
    
    init(loadingNewQuestions: Binding<Bool>, currentQuestions: Binding<String>) {
        _loadingNewQuestions = loadingNewQuestions
        _currentQuestions = currentQuestions
        qlist = currentQuestions.wrappedValue.components(separatedBy: .newlines).filter { !$0.isEmpty }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            VStack(alignment: .leading, spacing: 10) {
                ForEach(qlist.indices) { index in
                    QuestionBlock(index: index, question: formatQuestion(qlist[index]))
                        .accessibilityValue("\(index + 1) of \(qlist.count)")
                        .redacted(reason: loadingNewQuestions ? .placeholder : [])
                        .disabled(loadingNewQuestions)
                }
            }
            
//            Button(action: {
//                withAnimation {
//                    // refresh description
//                }
//            }) {
//                Label("Refresh questions", systemImage: "arrow.counterclockwise")
//            }
//            .padding(.horizontal, 10)
//            .padding(.vertical, 8)
//            .font(.caption)
//            .fontWeight(.medium)
//            .background(.regularMaterial, in: Capsule())
//            .buttonStyle(PlainButtonStyle())
//            .frame(maxWidth: .infinity, alignment: .center)
//            .padding(.vertical)
//            Divider()
//                .padding(.bottom)
//            VStack(alignment: .center, spacing: 20) {
//                Text("Want to ask about any of these?")
//                    .font(.headline)
//                    .fontWeight(.semibold)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal,20)
//                QuestionSuggestions()
//            }
        }
        .padding(.horizontal)
        .padding(5)
    }
    
    private func formatQuestion(_ text: String) -> String {
        let pattern = "^\\d+\\.\\s*"
        if let range = text.range(of: pattern, options: .regularExpression) {
            return String(text[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return text
    }
}

struct QuestionBlock: View {
    
    let pasteboard = UIPasteboard.general
    var index: Int
    var question: String
    
    var body: some View {
        VStack {
            HStack {
                Text("Question \(index + 1)")
                    .fontWeight(.semibold)
                    .font(.subheadline)
                Spacer()
                Button(action: {
                    pasteboard.string = question
                }) {
                    Label("Copy", systemImage: "doc.on.doc")
                }
                .background(.ultraThinMaterial)
                .buttonStyle(SmallButtonStyle())
                .clipShape(.capsule)
            }
            Text(question)
                .fontWeight(.semibold)
                .font(.title3)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
    }
}



struct QuestionSuggestions: View {
    
    
    let items = ["Colors", "“Smiling sun”", "Inspiration", "Memory", "“Green house”"]
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .center) {
                ForEach(items.prefix(3), id: \.self) { text in
                    Button(text) {
                        
                    }
                    .fontWeight(.medium)
                    .foregroundStyle(.purple)
                    .buttonBorderShape(.roundedRectangle)
                    .buttonStyle(BorderedButtonStyle())
                }
            }
            HStack(alignment: .center) {
                ForEach(items.suffix(2), id: \.self) { text in
                    Button(text) {
                    }
                    .fontWeight(.medium)
                    .foregroundStyle(.purple)
                    .buttonBorderShape(.roundedRectangle)
                    .buttonStyle(BorderedButtonStyle())
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
