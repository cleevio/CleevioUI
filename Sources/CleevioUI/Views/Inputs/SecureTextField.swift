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
    public init(_ placeholder: String, text: Binding<String>, type: SecureFieldType = .normal, configuration: RevealTextFieldLabelConfiguration<ButtonLabel>) {
        self.placeholder = placeholder
        self._text = text
        self.type = type
        self.buttonLabel = configuration
    }
    
    /// The configuration for the button label used to reveal the text.
    var buttonLabel: RevealTextFieldLabelConfiguration<ButtonLabel>
    
    /// The placeholder text to display when the text field is empty.
    public var placeholder: String
    
    /// A binding to the entered text.
    @Binding var text: String
    
    /// The type of the text field.
    public var type: SecureFieldType = .normal
    
    /// The prompt text to display when the text field is empty.
    private var textFieldPrompt: Text {
        Text(placeholder)
    }
    
    /// The body of the text field view.
    public var body: some View {
        switch type {
        case .normal:
            TextField(text: $text, prompt: textFieldPrompt, label: { Text(placeholder) })
        case .secure:
            SecureField(text: $text, prompt: textFieldPrompt, label: { Text(placeholder) })
        case .reveal:
            RevealTextField(placeholder, text: $text, configuration: buttonLabel)
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
    public init(_ placeholder: String, text: Binding<String>, type: SecureFieldType = .normal, configuration: RevealTextFieldLabelConfiguration<Image>? = nil) {
        self.placeholder = placeholder
        self._text = text
        self.type = type
        self.buttonLabel = configuration ?? .init()
    }
}

/// A text field that can be used to securely enter sensitive information, with a button that reveals the entered text.
@available(iOS 15.0, *)
public struct RevealTextField<ButtonLabel: View>: View {
    
    /// The placeholder text to display when the text field is empty.
    public var placeholder: String
    
    /// The configuration for the button label used to reveal the text.
    var buttonLabel: RevealTextFieldLabelConfiguration<ButtonLabel>
    
    /// A binding to the entered text.
    @Binding var text: String
    
    /// The type of the text field.
    @State private var type: SecureFieldType = .secure
    
    /// Whether the text field is currently focused.
    @FocusState private var isFocused: Bool
    
    /// Initializes a new instance of `RevealTextField`.
    ///
    /// - Parameters:
    ///   - placeholder: A string that describes the purpose of the text field.
    ///   - text: A binding to a string value that represents the contents of the text field.
    ///   - configuration: A configuration for the label of the reveal button.
    public init(_ placeholder: String, text: Binding<String>, configuration: RevealTextFieldLabelConfiguration<ButtonLabel>) {
        self.placeholder = placeholder
        self._text = text
        self.buttonLabel = configuration
    }
    
    public var body: some View {
        HStack {
            SecureTextField(placeholder, text: $text, type: type, configuration: buttonLabel)
                .focused($isFocused)
            
            Button {
                type = type == .secure ? .normal : .secure
            } label: {
                buttonLabel.changeTextFieldTypeButtonLabel(type)
            }
            
        }
        .onChange(of: type) { _ in
            guard isFocused else { return }
            DispatchQueue.main.async {
                self.isFocused = true
            }
        }
    }
}

@available(iOS 15.0, *)
extension RevealTextField where ButtonLabel == Image {
    public init(_ placeholder: String, text: Binding<String>, configuration: RevealTextFieldLabelConfiguration<Image>? = nil) {
        self.placeholder = placeholder
        self._text = text
        self.buttonLabel = configuration ?? .init()
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

public struct RevealTextFieldLabelConfiguration<Label: View> {
    /// A closure that receives the current secure text field type and returns a label to display the button for switching between normal and secure modes.
    var changeTextFieldTypeButtonLabel: (SecureFieldType) -> (Label)
    
    /// Initializes a new instance with the given closure that provides a label to display the button for switching between normal and secure modes.
    public init(changeTextFieldTypeButtonLabel: @escaping (SecureFieldType) -> (Label)) {
        self.changeTextFieldTypeButtonLabel = changeTextFieldTypeButtonLabel
    }
}

extension RevealTextFieldLabelConfiguration where Label == Image {
    /// Initializes a new instance with the default images for the secure text field button.
    public init() {
        self.init(changeTextFieldTypeButtonLabel: { type in
            Image(systemName: type == .secure ? "eye.slash" : "eye")
        })
    }
    
    /// Initializes a new instance with the specified images for the secure text field button.
    ///
    /// - Parameters:
    ///   - eye: The image to use for the "unmasked" button.
    ///   - crossedEye: The image to use for the "masked" button.
    public init(eye: Image, crossedEye: Image) {
        self.init(changeTextFieldTypeButtonLabel: { type in
            type == .secure ? eye : crossedEye
        })
    }
}
