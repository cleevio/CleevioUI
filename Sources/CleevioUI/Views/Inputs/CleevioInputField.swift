import SwiftUI

/// A structure representing the setting of an input field.
public struct CleevioInputFieldOptions: OptionSet, Hashable, Sendable {
    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    /// Adds tap gesture on content to handle focus.
    public static let handlesFocus = CleevioInputFieldOptions(rawValue: 1 << 0)
    /// Hides the error label when the input field is disabled.
    public static let hideErrorIfDisabled = CleevioInputFieldOptions(rawValue: 1 << 1)
    /// Hides the error label when the input field is focused.
    public static let hideErrorIfFocused = CleevioInputFieldOptions(rawValue: 1 << 2)

    /// The default options for the input field
    public static let `default`: Self = [.handlesFocus]
}

/// A customizable input field style serving as a wrapper for various types such as `TextField` or `Picker`.
///
/// This structure provides a way to define the appearance and behavior of input fields, including customizability based on different states such as focused, enabled, or error.
///
/// Usage:
/// - Create a `CleevioInputField` with custom content, appearance, and behavior.
/// - Configure the title, text color, background, overlay, error label, and other properties to suit your needs.
/// - The input field can automatically handle focus and error states, making it suitable for various forms and data entry scenarios.
///
/// Example:
/// ```swift
/// let configuration = CleevioInputField.Configuration(
///     title: {
///         Text("Email")
///     },
///     foreground: { state in
///         state.isError ? .red : .primary
///     },
///     background: { state in
///         RoundedRectangle(cornerRadius: 8)
///             .fill(state.isFocused ? .blue : .gray)
///     },
///     overlay: { state in
///         RoundedRectangle(cornerRadius: 8)
///             .stroke(state.isFocused ? .blue : .gray, lineWidth: 2)
///     },
///     errorLabel: { error in
///         Text(error)
///             .foregroundColor(.red)
///     },
///     isFocused: false,
///     contentPadding: .all(8),
///     font: .body
/// )
///
/// CleevioInputField(content: { state in
///     TextField("Enter your email", text: $email)
///         .keyboardType(.emailAddress)
/// }, configuration: configuration)
/// ```
///
@available(iOS 15.0, macOS 12.0, *)
public struct CleevioInputField<
    Content: View,
    Title: View,
    Background: View,
    Overlay: View,
    ErrorLabel: View
>: View {
    public struct Configuration {
        @ViewBuilder let title: (InputFieldState) -> Title
        @ViewBuilder let foreground: (InputFieldState) -> Color
        @ViewBuilder let background: (InputFieldState) -> Background
        @ViewBuilder let overlay: (InputFieldState) -> Overlay
        @ViewBuilder let errorLabel: (String) -> ErrorLabel

        /// When @FocusState is not available, this value is used to invoke focus state appearance/behavior
        let isExternallyFocused: Bool
        let contentPadding: EdgeInsets
        let font: Font?

        /// The configuration options for the input field.
        let options: CleevioInputFieldOptions

        var shouldHandleFocus: Bool {
            options.contains(.handlesFocus)
        }

        public init(
            @ViewBuilder title: @escaping (InputFieldState) -> Title,
            @ViewBuilder foreground: @escaping (InputFieldState) -> Color,
            @ViewBuilder background: @escaping (InputFieldState) -> Background,
            @ViewBuilder overlay: @escaping (InputFieldState) -> Overlay,
            @ViewBuilder errorLabel: @escaping (String) -> ErrorLabel,
            isFocused: Bool,
            contentPadding: EdgeInsets,
            font: Font?,
            options: CleevioInputFieldOptions = .default
        ) {
            self.title = title
            self.foreground = foreground
            self.background = background
            self.overlay = overlay
            self.errorLabel = errorLabel
            self.isExternallyFocused = isFocused
            self.contentPadding = contentPadding
            self.font = font
            self.options = options
        }
    }

    @usableFromInline
    @ViewBuilder var content: (InputFieldState) -> Content

    public var configuration: Configuration

    @FocusState private var isFocused: Bool
    @Environment(\.stringError) private var error: String?
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.colorScheme) private var colorScheme

    @inlinable
    public init(
        @ViewBuilder content: @escaping (InputFieldState) -> Content,
        configuration: Configuration
    ) {
        self.content = content
        self.configuration = configuration
    }

    var state: InputFieldState {
        let isFocused = isFocused || configuration.isExternallyFocused
        let isError: Bool = {
            guard error != nil else {
                return false
            }
            if configuration.options.contains(.hideErrorIfFocused) && isFocused {
                return false
            }
            if configuration.options.contains(.hideErrorIfDisabled) && !isEnabled {
                return false
            }
            return true
        }()

        return .init(
            isFocused: isFocused,
            isEnabled: isEnabled,
            isError: isError
        )
    }

    public var body: some View {
        let state = state

        VStack(alignment: .leading, spacing: 6) {
            configuration.title(state)

            VStack(alignment: .leading, spacing: .zero) {
                if configuration.shouldHandleFocus {
                    contentView
                        .onTapGesture {
                            isFocused = true
                        }
                        // Defocus on color scheme change.
                        // This is a workaround for a bug in SwiftUI, where textfield foreground color is sometimes not updated when it is focused
                        // and color scheme changes.
                        .onChange(of: colorScheme) { _ in
                            isFocused = false
                        }
                } else {
                    contentView
                }

                configuration.errorLabel(error ?? "")
                    .opacity(state.isError ? 1 : 0)
                    .frame(height: state.isError ? nil : 0)
                    .padding(.top, state.isError ? 6 : 0)
            }
        }
        .foregroundStyle(configuration.foreground(state))
        .tint(configuration.foreground(state))
        .font(configuration.font)
        .animation(.default, value: self.state)
        .animation(.easeInOut, value: isEnabled)
    }

    private var contentView: some View {
        content(state)
            .focused($isFocused)
            .padding(configuration.contentPadding)
            .background(configuration.background(state))
            .overlay { configuration.overlay(state) }
            .contentShape(Rectangle())
    }
}

// MARK: - Helpers

@available(iOS 15.0, macOS 12.0, *)
public extension CleevioInputField.Configuration where Content: View, Title: View, Background == Color, Overlay == RoundedStroke, ErrorLabel == Text {
    /// Creates a `CleevioInputField.Configuration` with specific color sets and visual properties for convenience.
    ///
    /// This initializer simplifies the configuration of a `CleevioInputField` by specifying color sets and visual properties for the input field's appearance. It is particularly useful for quickly defining the appearance of an input field with consistent color and style choices.
    ///
    /// - Parameters:
    ///   - title: A function builder for the title view.
    ///   - foregroundColorSet: A color set that defines text colors for different input field states.
    ///   - backgroundColorSet: A color set that defines background colors for different input field states.
    ///   - strokeColorSet: A color set that defines stroke (border) colors for different input field states.
    ///   - isFocused: A boolean indicating whether the input field is focused.
    ///   - contentPadding: Padding for the content of the input field.
    ///   - font: The font used for the input field.
    ///   - cornerRadius: The corner radius for the input field.
    ///
    /// Example:
    /// ```swift
    /// let colorSet = InputFieldStateColorSet(
    ///     normal: .gray,
    ///     focused: .blue,
    ///     error: .red
    /// )
    ///
    /// let configuration = CleevioInputField.Configuration(
    ///     title: {
    ///         Text("Username")
    ///     },
    ///     foregroundColorSet: colorSet,
    ///     backgroundColorSet: colorSet,
    ///     strokeColorSet: colorSet,
    ///     isFocused: false,
    ///     contentPadding: .all(8),
    ///     font: .body
    ///     cornerRadius: 8
    /// )
    /// ```
    ///
    @MainActor
    init(
        title: @escaping (InputFieldState) -> Title,
        foregroundColorSet: InputFieldStateColorSet,
        backgroundColorSet: InputFieldStateColorSet,
        strokeColorSet: InputFieldStateColorSet,
        isFocused: Bool = false,
        contentPadding: EdgeInsets,
        font: Font,
        cornerRadius: CGFloat
    ) {
        self.init(
            title: title,
            foreground: foregroundColorSet.resolve,
            background: backgroundColorSet.resolve,
            overlay: {
                RoundedStroke(
                    color: strokeColorSet.resolve($0),
                    cornerRadius: cornerRadius
                )
            },
            errorLabel: { Text($0) },
            isFocused: isFocused,
            contentPadding: contentPadding,
            font: font
        )
    }
}

@available(iOS 15.0, macOS 12.0, *)
public extension CleevioInputField {
    /// Creates a `CleevioInputField` with a specific `CleevioTextField` content for convenience.
    ///
    /// This initializer simplifies the creation of a `CleevioInputField` with a `CleevioTextField` as its content, providing a type-specific input field with various customization options.
    /// It is particularly useful for creating input fields that require additional buttons, such as secure text fields with reveal buttons.
    ///
    /// - Parameters:
    ///   - type: The type of the input field (e.g., secure text, plain text).
    ///   - placeholder: A function builder to define the placeholder text based on the input field state.
    ///   - text: A binding to the text entered in the input field.
    ///   - revealTextFieldLabel: A function builder to define the reveal button label based on the input field state.
    ///   - configuration: The configuration for the `CleevioInputField`.
    ///
    /// Example:
    /// ```swift
    /// CleevioInputField(
    ///     type: .secure,
    ///     placeholder: { state in
    ///         state.isFocused ? Text("Enter your password") : Text("Password")
    ///     },
    ///     text: $password,
    ///     revealTextFieldLabel: { state in
    ///         { type in
    ///             Image(systemName: type == .secure ? "eye.slash" : "eye")
    ///         }
    ///     },
    ///     configuration: configuration
    /// )
    /// ```
    init<ButtonLabel: View>(
        type: CleevioTextFieldType,
        placeholder: @escaping (InputFieldState) -> Text?,
        text: Binding<String>,
        revealTextFieldLabel: @escaping (InputFieldState) -> ((CleevioTextFieldType) -> ButtonLabel),
        configuration: Configuration
    ) where Content == CleevioTextField<ButtonLabel> {
        self.init(
            content: { state in
                CleevioTextField("", text: text, prompt: placeholder(state), type: type, buttonLabel: revealTextFieldLabel(state))
            },
            configuration: configuration
        )
    }
}

@available(iOS 15.0, macOS 12.0, *)
public extension CleevioInputField where Content == CleevioTextField<RevealTextFieldIcon>, Title: View, Background == Color, Overlay == RoundedStroke, ErrorLabel == Text {
    /// Creates a `CleevioInputField` with a `CleevioTextField` content, and specific visual properties for convenience.
    ///
    /// This initializer simplifies the creation of a `CleevioInputField` with a `CleevioTextField` containing a reveal button for secure text entry. It allows you to specify visual properties, including the placeholder text color, the reveal button label color, and the overall configuration of the input field.
    ///
    /// - Parameters:
    ///   - type: The type of the input field (e.g., secure text, plain text).
    ///   - placeholder: The placeholder text for the input field.
    ///   - text: A binding to the text entered in the input field.
    ///   - placeholderColorSet: A color set that defines the placeholder text color for different input field states.
    ///   - revealTextFieldLabelColorSet: A color set that defines the reveal button label color for different input field states.
    ///   - configuration: The configuration for the `CleevioInputField`.
    ///
    /// Example:
    /// ```swift
    /// let placeholderColorSet = InputFieldStateColorSet(
    ///     normal: .gray,
    ///     focused: .blue,
    ///     error: .red
    /// )
    ///
    /// let revealLabelColorSet = InputFieldStateColorSet(
    ///     normal: .gray,
    ///     focused: .blue,
    ///     error: .red
    /// )
    ///
    /// let configuration = CleevioInputField.Configuration(
    ///     title: {
    ///         Text("Password")
    ///     },
    ///     foregroundColorSet: placeholderColorSet,
    ///     backgroundColorSet: .init(normal: .white, focused: .blue, error: .red),
    ///     strokeColorSet: .init(normal: .gray, focused: .blue, error: .red),
    ///     isFocused: false,
    ///     contentPadding: .all(8),
    ///     font: .body,
    ///     cornerRadius: 8
    /// )
    ///
    /// CleevioInputField(
    ///     type: .secure,
    ///     placeholder: "Enter your password",
    ///     text: $password,
    ///     placeholderColorSet: placeholderColorSet,
    ///     revealTextFieldLabelColorSet: revealLabelColorSet,
    ///     configuration: configuration
    /// )
    /// ```
    init(
        type: CleevioTextFieldType = .normal,
        placeholder: String?,
        text: Binding<String>,
        placeholderColorSet: InputFieldStateColorSet,
        revealTextFieldLabelColorSet: InputFieldStateColorSet,
        configuration: Configuration
    ) {
        self.init(
            type: type,
            placeholder: { state in
                let color: Color = placeholderColorSet.resolve(state)
                return placeholder.map {
                    if #available(iOS 17.0, macOS 14.0,  watchOS 10, *) {
                        Text($0).foregroundStyle(color).font(configuration.font)
                    } else {
                        Text($0).foregroundColor(color).font(configuration.font)
                    }
                }
            },
            text: text,
            revealTextFieldLabel: { state in
                { type in
                    RevealTextFieldIcon.systemEye(
                        CleevioTextFieldType: type,
                        configuration: .init(
                            foregroundColor: revealTextFieldLabelColorSet.resolve(state)
                        )
                    )
                }
            },
            configuration: configuration
        )
    }
}
