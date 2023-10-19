//
//  CleevioTextField.swift
//  
//
//  Created by Lukáš Valenta on 17.04.2023.
//

import SwiftUI

/// A text field that can be used to securely enter sensitive information, with support for revealing the entered text.
@available(iOS 15.0, *)
public struct CleevioTextField<ButtonLabel: View>: View {

    /// Initializes a new instance of `CleevioTextField`.
    ///
    /// - Parameters:
    ///   - placeholder: The placeholder text to display when the text field is empty.
    ///   - text: A binding to the entered text.
    ///   - type: The type of the text field.
    ///   - configuration: The configuration for the button label used to reveal the text.
    public init(_ placeholder: String, text: Binding<String>, prompt: Text? = nil, type: CleevioTextFieldType = .normal, @ViewBuilder buttonLabel: @escaping (CleevioTextFieldType) -> ButtonLabel) {
        self.placeholder = placeholder
        self._text = text
        self.type = type
        self.prompt = prompt
        self.buttonLabel = buttonLabel
    }

    /// The configuration for the button label used to reveal the text.
    @ViewBuilder var buttonLabel: (CleevioTextFieldType) -> ButtonLabel

    /// The placeholder text to display when the text field is empty.
    public var placeholder: String

    /// A binding to the entered text.
    @Binding var text: String

    /// The type of the text field.
    public var type: CleevioTextFieldType = .normal

    /// The prompt text to display when the text field is empty.
    private var prompt: Text?

    /// The body of the text field view.
    public var body: some View {
        switch type {
        case .normal:
            TextField(text: $text, prompt: prompt, label: { Text(placeholder) })
        case .secure:
            SecureField(text: $text, prompt: prompt, label: { Text(placeholder) })
                // This is a hack that makes the SecureField the same height as TextField.
                // Be aware that this can be system dependent so update accordingly
                .padding(.vertical, 5/6.0)
        case .reveal:
            RevealTextField(placeholder, text: $text, prompt: prompt, buttonLabel: buttonLabel)
        }
    }
}

@available(iOS 15.0, *)
extension CleevioTextField where ButtonLabel == Image {
    
    /// Initializes a new instance of `CleevioTextField` with the button label configured to use the specified images.
    ///
    /// - Parameters:
    ///   - placeholder: The placeholder text to display when the text field is empty.
    ///   - text: A binding to the entered text.
    ///   - type: The type of the text field.
    ///   - configuration: The configuration for the button label used to reveal the text.
    public init(_ placeholder: String, text: Binding<String>, type: CleevioTextFieldType = .normal, image: @escaping (CleevioTextFieldType) -> Image) {
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
    @ViewBuilder var buttonLabel: (CleevioTextFieldType) -> ButtonLabel

    /// A binding to the entered text.
    @Binding var text: String
    
    /// The type of the text field.
    @State private var type: CleevioTextFieldType = .secure
    
    /// Whether the text field is currently focused.
    @FocusState private var isFocused: Bool

    private var prompt: Text?

    /// Initializes a new instance of `RevealTextField`.
    ///
    /// - Parameters:
    ///   - placeholder: A string that describes the purpose of the text field.
    ///   - text: A binding to a string value that represents the contents of the text field.
    ///   - configuration: A configuration for the label of the reveal button.
    public init(_ placeholder: String, text: Binding<String>, prompt: Text?, @ViewBuilder buttonLabel: @escaping (CleevioTextFieldType) -> ButtonLabel) {
        self.placeholder = placeholder
        self._text = text
        self.prompt = prompt
        self.buttonLabel = buttonLabel
    }
    
    public var body: some View {
        HStack {
            CleevioTextField(placeholder, text: $text, prompt: prompt, type: type, buttonLabel: buttonLabel)
                .focused($isFocused)

            Button {
                type = type == .secure ? .normal : .secure
            } label: {
                buttonLabel(type)
            }
        }
        .onChange(of: type) { _ in
            guard isFocused else { return }
            // since previously focused TextField is getting destroyed (CleevioTextField and TextField are different types)
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
public enum CleevioTextFieldType {
    /// A regular text field without any obscuring of input.
    case normal
    /// A secure TextField that obscures the user's input.
    case secure
    /// A TextField with eye to switch between normal and secure type
    case reveal
}

/// A view representing an icon used to toggle between a secure text field and a revealed text field.
public struct RevealTextFieldIcon: View {
    /// Configuration for the RevealTextFieldIcon.
    public struct Configuration {
        /// The size of the icon.
        var size: CGSize
        /// The tappable size of the icon.
        var tappableSize: CGSize
        /// The foreground color of the icon.
        var foregroundColor: Color

        /// Initializes a Configuration for RevealTextFieldIcon.
        ///
        /// - Parameters:
        ///   - size: The size of the icon (default is 24x24).
        ///   - tappableSize: The tappable size of the icon (default is 40x40).
        ///   - foregroundColor: The foreground color of the icon.
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

    /// Initializes a RevealTextFieldIcon with the specified icon and configuration.
    ///
    /// - Parameters:
    ///   - icon: The icon image to display.
    ///   - configuration: The configuration for the icon.
    public init(_ icon: Image, configuration: Configuration) {
        self.icon = icon
        self.configuration = configuration
    }

    public var sizedIcon: some View {
        icon
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(size: configuration.size, alignment: .center)
            .background(Color.white)
            .frame(size: configuration.tappableSize, alignment: .center)
            .background(Color.green)
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
    /// Creates a RevealTextFieldIcon with a system eye icon (secure or revealed) based on the specified CleevioTextFieldType.
    ///
    /// - Parameters:
    ///   - type: The CleevioTextFieldType indicating whether the icon should represent a secure or revealed state.
    ///   - configuration: The configuration for the icon.
    public static func systemEye(CleevioTextFieldType type: CleevioTextFieldType, configuration: Configuration) -> Self {
        .init(
            Image(systemName: type == .secure ? "eye.slash" : "eye"),
            configuration: configuration
        )
    }

    /// Creates a RevealTextFieldIcon with custom eye icons (secure and crossed) based on the specified CleevioTextFieldType.
    ///
    /// - Parameters:
    ///   - eye: The image for the eye (secure) state.
    ///   - crossed: The image for the crossed (revealed) state.
    ///   - configuration: The configuration for the icon.
    public static func customEye(_ eye: Image, crossed: Image, configuration: Configuration) -> (CleevioTextFieldType) -> Self {
        { type in
            .init(
                type == .secure ? crossed : eye,
                configuration: configuration
            )
        }
    }
}

@available(iOS 15.0, *)
struct CleevioTextField_Preview: PreviewProvider {
    static var previews: some View {
        VStack {
            CleevioTextField("Hello", text: .constant("Text"), buttonLabel: { _ in EmptyView() })
                .background(Color.red)
                .padding(10)
                .background(Color.blue)

            CleevioTextField("Hello", text: .constant("Text"), type: .reveal, buttonLabel: { RevealTextFieldIcon.systemEye(CleevioTextFieldType: $0, configuration: .init(foregroundColor: .orange)) })
                .readSize(onChange: { print($0) })
                .font(.system(size: 40))
                .background(Color.red)
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 5))
                .background(Color.blue)
        }
    }
}
