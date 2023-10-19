//
//  SecureTextField.swift
//  
//
//  Created by Lukáš Valenta on 17.04.2023.
//

import SwiftUI

/// A text field that can be used to securely enter sensitive information, with support for revealing the entered text.
@available(iOS 15.0, *)
public struct SecureTextField<ButtonLabel: View>: View {
    
    /// Initializes a new instance of `SecureTextField`.
    ///
    /// - Parameters:
    ///   - placeholder: The placeholder text to display when the text field is empty.
    ///   - text: A binding to the entered text.
    ///   - type: The type of the text field.
    ///   - configuration: The configuration for the button label used to reveal the text.
    public init(_ placeholder: String, text: Binding<String>, prompt: Text?, type: SecureFieldType = .normal, @ViewBuilder buttonLabel: @escaping (SecureFieldType) -> ButtonLabel) {
        self.placeholder = placeholder
        self._text = text
        self.type = type
        self.prompt = prompt
        self.buttonLabel = buttonLabel
    }
    
    /// The configuration for the button label used to reveal the text.
    @ViewBuilder var buttonLabel: (SecureFieldType) -> ButtonLabel

    /// The placeholder text to display when the text field is empty.
    public var placeholder: String
    
    /// A binding to the entered text.
    @Binding var text: String
    
    /// The type of the text field.
    public var type: SecureFieldType = .normal
    
    /// The prompt text to display when the text field is empty.
    private var prompt: Text?

    /// The body of the text field view.
    public var body: some View {
        switch type {
        case .normal:
            TextField(text: $text, prompt: prompt, label: { Text(placeholder) })
        case .secure:
            SecureField(text: $text, prompt: prompt, label: { Text(placeholder) })
        case .reveal:
            RevealTextField(placeholder, text: $text, prompt: prompt, buttonLabel: buttonLabel)
        }
    }
}

@available(iOS 15.0, *)
extension SecureTextField where ButtonLabel == Image {
    
    /// Initializes a new instance of `SecureTextField` with the button label configured to use the specified images.
    ///
    /// - Parameters:
    ///   - placeholder: The placeholder text to display when the text field is empty.
    ///   - text: A binding to the entered text.
    ///   - type: The type of the text field.
    ///   - configuration: The configuration for the button label used to reveal the text.
    public init(_ placeholder: String, text: Binding<String>, type: SecureFieldType = .normal, image: @escaping (SecureFieldType) -> Image) {
        self.placeholder = placeholder
        self._text = text
        self.type = type
        self.buttonLabel = image
    }
}

/// A text field that can be used to securely enter sensitive information, with a button that reveals the entered text.
@available(iOS 15.0, *)
public struct RevealTextField<ButtonLabel: View>: View {
    
    /// The placeholder text to display when the text field is empty.
    public var placeholder: String
    
    /// The configuration for the button label used to reveal the text.
    @ViewBuilder var buttonLabel: (SecureFieldType) -> ButtonLabel

    /// A binding to the entered text.
    @Binding var text: String
    
    /// The type of the text field.
    @State private var type: SecureFieldType = .secure
    
    /// Whether the text field is currently focused.
    @FocusState private var isFocused: Bool

    private var prompt: Text?

    /// Initializes a new instance of `RevealTextField`.
    ///
    /// - Parameters:
    ///   - placeholder: A string that describes the purpose of the text field.
    ///   - text: A binding to a string value that represents the contents of the text field.
    ///   - configuration: A configuration for the label of the reveal button.
    public init(_ placeholder: String, text: Binding<String>, prompt: Text?, @ViewBuilder buttonLabel: @escaping (SecureFieldType) -> ButtonLabel) {
        self.placeholder = placeholder
        self._text = text
        self.prompt = prompt
        self.buttonLabel = buttonLabel
    }
    
    public var body: some View {
        HStack {
            SecureTextField(placeholder, text: $text, prompt: prompt, type: type, buttonLabel: buttonLabel)
                .focused($isFocused)
            
            Button {
                type = type == .secure ? .normal : .secure
            } label: {
                buttonLabel(type)
            }
            
        }
        .onChange(of: type) { _ in
            guard isFocused else { return }
            // since previously focused TextField is getting destroyed (SecureTextField and TextField are different types)
            // and is leaving View hierarchy, we want to set the focus to the "new one" so that pressing in label does not lose focus.
            DispatchQueue.main.async {
                self.isFocused = true
            }
        }
    }
}

/**
 A type representing the type of secure text field to display.
 
 - `normal`: A regular text field without any obscuring of input.
 - `secure`: A secure text field that obscures the user's input.
 - `reveal`: A text field with an eye button that toggles between regular and secure input modes.
 */
public enum SecureFieldType {
    /// A regular text field without any obscuring of input.
    case normal
    /// A secure TextField that obscures the user's input.
    case secure
    /// A TextField with eye to switch between normal and secure type
    case reveal
}

public struct RevealTextFieldIcon: View {
    public struct Configuration {
        var size: CGSize
        var tappableSize: CGSize
        var foregroundColor: Color

        public init(
            size: CGSize = .init(width: 24, height: 24),
            tappableSize: CGSize = .init(width: 40, height: 40),
            foregroundColor: Color
        ) {
            self.size = size
            self.tappableSize = tappableSize
            self.foregroundColor = foregroundColor
        }
    }

    var icon: Image
    var configuration: Configuration

    public init(_ icon: Image, configuration: Configuration) {
        self.icon = icon
        self.configuration = configuration
    }

    public var sizedIcon: some View {
        icon
            .resizable()
            .frame(size: configuration.size, alignment: .center)
            .frame(size: configuration.tappableSize, alignment: .center)
    }

    public var body: some View {
        Group {
            if #available(iOS 15.0, *) {
                sizedIcon.foregroundStyle(configuration.foregroundColor)
            } else {
                sizedIcon.foregroundColor(configuration.foregroundColor)
            }
        }
        .contentShape(Rectangle())
    }
}

extension RevealTextFieldIcon {
    public static func systemEye(secureFieldType type: SecureFieldType, configuration: Configuration) -> Self {
        .init(
            Image(systemName: type == .secure ? "eye.slash" : "eye"),
            configuration: configuration
        )
    }

    public static func customEye(_ eye: Image, crossed: Image, configuration: Configuration) -> (SecureFieldType) -> Self {
        { type in
            .init(
                type == .secure ? crossed : eye,
                configuration: configuration
            )
        }
    }
}
