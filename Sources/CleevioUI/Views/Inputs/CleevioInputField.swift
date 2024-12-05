import SwiftUI

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
        @ViewBuilder var title: (InputFieldState) -> Title
        @ViewBuilder var foreground: (InputFieldState) -> Color
        @ViewBuilder var background: (InputFieldState) -> Background
        @ViewBuilder var overlay: (InputFieldState) -> Overlay
        @ViewBuilder var errorLabel: (String) -> ErrorLabel

        /// When @FocusState is not available, this value is used to invoke focus state appearance/behavior
        var isExternallyFocused: Bool = false
        var contentPadding: EdgeInsets
        var font: Font?

        /// Condition defining when the error label should be presented.
        let errorPresentationCondition: (_ isFocused: Bool, _ error: String?) -> Bool

        public init(
            @ViewBuilder title: @escaping (InputFieldState) -> Title,
            @ViewBuilder foreground: @escaping (InputFieldState) -> Color,
            @ViewBuilder background: @escaping (InputFieldState) -> Background,
            @ViewBuilder overlay: @escaping (InputFieldState) -> Overlay,
            @ViewBuilder errorLabel: @escaping (String) -> ErrorLabel,
            isFocused: Bool,
            contentPadding: EdgeInsets,
            font: Font?
        ) {
            self.title = title
            self.foreground = foreground
            self.background = background
            self.overlay = overlay
            self.errorLabel = errorLabel
            self.isExternallyFocused = isFocused
            self.contentPadding = contentPadding
            self.font = font

            self.errorPresentationCondition = { _, error in error != nil }
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
            errorPresentationCondition: @escaping (_ isFocused: Bool, _ error: String?) -> Bool
        ) {
            self.title = title
            self.foreground = foreground
            self.background = background
            self.overlay = overlay
            self.errorLabel = errorLabel
            self.isExternallyFocused = isFocused
            self.contentPadding = contentPadding
            self.font = font

            self.errorPresentationCondition = errorPresentationCondition
        }
    }

    @usableFromInline
    @ViewBuilder var content: (InputFieldState) -> Content

    public var configuration: Configuration

    @FocusState private var isFocused: Bool
    @Environment(\.stringError) private var error: String?
    @Environment(\.isEnabled) private var isEnabled

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
        return .init(
            isFocused: isFocused,
            isEnabled: isEnabled,
            isError: configuration.errorPresentationCondition(isFocused, error)
        )
    }

    var isErrorPresented: Bool {
        state.isError
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            let state = state
            configuration.title(state)

            VStack(alignment: .leading, spacing: .zero) {
                content(state)
                    .focused($isFocused)
                    .padding(configuration.contentPadding)
                    .background(configuration.background(state))
                    .overlay { configuration.overlay(state) }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isFocused = true
                    }

                configuration.errorLabel(error ?? "")
                    .opacity(isErrorPresented ? 1 : 0)
                    .frame(height: isErrorPresented ? nil : 0)
                    .padding(.top, isErrorPresented ? 6 : 0)
            }
        }
        .foregroundStyle(configuration.foreground(state))
        .tint(configuration.foreground(state))
        .font(configuration.font)
        .animation(.default, value: isErrorPresented)
        .animation(.easeInOut, value: state.isFocused)
        .animation(.easeInOut, value: isEnabled)
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
