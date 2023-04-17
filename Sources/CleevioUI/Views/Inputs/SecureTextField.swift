//
//  SwiftUIView.swift
//  
//
//  Created by Lukáš Valenta on 17.04.2023.
//

import SwiftUI

@available(iOS 15.0, *)
struct SecureTextField: View {
    init(_ placeholder: String, text: Binding<String>, type: SecureFieldType = .normal) {
        self.placeholder = placeholder
        self._text = text
        self.type = type
    }

    var placeholder: String
    @Binding var text: String
    var type: SecureFieldType = .normal

    private var textFieldPrompt: Text {
        Text(placeholder)
    }

    var body: some View {
        switch type {
        case .normal:
            TextField(text: $text, prompt: textFieldPrompt, label: { Text(placeholder) })
        case .secure:
            SecureField(text: $text, prompt: textFieldPrompt, label: { Text(placeholder) })
        case .reveal:
            RevealTextField(placeholder, text: $text)
        }
    }
}

@available(iOS 15.0, *)
public struct RevealTextField: View {
    let placeholder: String
    @Binding var text: String

    @State private var type: SecureTextField.SecureFieldType = .secure
    @FocusState private var isFocused: Bool

    init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    var body: some View {
        HStack {
            SecureTextField(placeholder, text: $text, type: type)

            Button {
                type = type == .secure ? .normal : .secure
            } label: {
                Image(type == .secure ? Images.eyeCrossed : Images.eye)
            }
        }
        .focused($isFocused)
        .onChange(of: type) { _ in
            guard isFocused else { return }
            DispatchQueue.main.async {
                self.isFocused = true
            }
        }
    }
}

extension SecureTextField {
    enum SecureFieldType {
        case normal
        case secure
        /// TextField with eye to switch between normal and secure type
        case reveal
    }
}
