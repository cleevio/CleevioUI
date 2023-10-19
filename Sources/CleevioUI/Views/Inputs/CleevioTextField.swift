import SwiftUI

@available(iOS 15.0, *)
public struct CleevioTextField<
    Title: View,
    Background: View,
    Overlay: View,
    ErrorLabel: View,
    RevealLabel: View
>: View {
    public struct Configuration {
        var padding: CGFloat = 32
    }

    var type: SecureFieldType
    @Binding var text: String
    var placeholder: (TextFieldState) -> Text?

    var title: Title
    @ViewBuilder var foreground: (TextFieldState) -> Color
    @ViewBuilder var background: (TextFieldState) -> Background
    @ViewBuilder var overlay: (TextFieldState) -> Overlay
    @ViewBuilder var errorLabel: (String) -> ErrorLabel
    var revealTextFieldLabel: (TextFieldState) -> (SecureFieldType) -> RevealLabel
    var labelPadding: EdgeInsets
    var font: Font
    var isExternallyFocused: Bool = false // what is this for?
    var configuration: Configuration

    @FocusState private var focusState: Bool
    @Environment(\.stringError) private var error: String?
    @Environment(\.isEnabled) private var isEnabled

    public init(
        type: SecureFieldType,
        text: Binding<String>,
        placeholder: @escaping (TextFieldState) -> Text?,
        @ViewBuilder title: () -> Title,
        @ViewBuilder foreground: @escaping (TextFieldState) -> Color,
        @ViewBuilder background: @escaping (TextFieldState) -> Background,
        @ViewBuilder overlay: @escaping (TextFieldState) -> Overlay,
        @ViewBuilder errorLabel: @escaping (String) -> ErrorLabel,
        revealTextFieldLabel: @escaping (TextFieldState) -> ((SecureFieldType) -> RevealLabel),
        labelPadding: EdgeInsets,
        font: Font,
        isExternallyFocused: Bool,
        configuration: Configuration
    ) {
        self.type = type
        self.placeholder = placeholder
        self._text = text
        self.title = title()
        self.foreground = foreground
        self.background = background
        self.overlay = overlay
        self.errorLabel = errorLabel
        self.revealTextFieldLabel = revealTextFieldLabel
        self.labelPadding = labelPadding
        self.font = font
        self.isExternallyFocused = isExternallyFocused
        self.configuration = configuration
    }

    var state: TextFieldState {
        .init(
            isFocused: focusState || isExternallyFocused,
            isEnabled: isEnabled,
            isError: error != nil,
            isTextEmpty: text.isEmpty
        )
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            title

            SecureTextField("", text: $text, prompt: placeholder(state), type: type, buttonLabel: revealTextFieldLabel(state))
                .padding(labelPadding)
                .background(background(state))
                .overlay { overlay(state) }
                .focused($focusState)
                .contentShape(Rectangle())
                .onTapGesture {
                    focusState = true
                }

            if let error {
                errorLabel(error)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .leading),
                            removal: .move(edge: .leading)
                        )
                    )
            }
        }
        .foregroundStyle(foreground(state))
        .tint(foreground(state))
        .font(font)
        .animation(.default, value: error)
        .animation(.easeInOut, value: state.isFocused)
        .animation(.easeInOut, value: isEnabled)
    }
}

// MARK: - Helpers

public struct TextFieldState {
    public var isFocused: Bool
    public var isEnabled: Bool
    public var isError: Bool
    public var isTextEmpty: Bool
}

public struct TextFieldStateColorSet {
    public var unfocused: Color
    public var focused: Color
    public var error: Color
    public var disabled: Color

    public var resolve: (TextFieldState) -> Color

    public init(unfocused: Color, focused: Color, error: Color, disabled: Color, resolve: @escaping (TextFieldState) -> Color) {
        self.unfocused = unfocused
        self.focused = focused
        self.error = error
        self.disabled = disabled
        self.resolve = resolve
    }

    public init(unfocused: Color, focused: Color, error: Color, disabled: Color) {
        self.unfocused = unfocused
        self.focused = focused
        self.error = error
        self.disabled = disabled
        self.resolve = { state in
            if state.isError { return error }
            if state.isFocused { return focused }
            if state.isEnabled { return unfocused }
            return disabled
        }
    }
}

public struct ForegroundColorImage: View {
    var image: Image
    var color: Color

    public init(image: Image, color: Color) {
        self.image = image
        self.color = color
    }

    public var body: some View {
        if #available(iOS 15.0, *) {
            image.foregroundStyle(color)
        } else {
            image.foregroundColor(color)
        }
    }
}

@available(iOS 15.0, *)
public extension CleevioTextField<Text, EmptyView, RoundedStroke, Text, ForegroundColorImage> {
    init(
        type: SecureFieldType = .normal,
        title: String,
        placeholder: String?,
        text: Binding<String>,
        foregroundColorSet: TextFieldStateColorSet,
        placeholderColorSet: TextFieldStateColorSet,
        strokeColorSet: TextFieldStateColorSet,
        revealTextFieldLabelColorSet: TextFieldStateColorSet,
        cornerRadius: CGFloat,
        labelPadding: EdgeInsets,
        font: Font
    ) {
        self.init(
            type: type,
            text: text,
            placeholder: { state in
                var color: Color = placeholderColorSet.resolve(state)
                return placeholder.map {
                    if #available(iOS 17.0, *) {
                        Text($0).foregroundStyle(color).font(font)
                    } else {
                        Text($0).foregroundColor(color).font(font)
                    }
                }
            },
            title: { Text(title) },
            foreground: foregroundColorSet.resolve,
            background: { _ in EmptyView() },
            overlay: {
                RoundedStroke(
                    color: strokeColorSet.resolve($0),
                    cornerRadius: cornerRadius
                )
            },
            errorLabel: { Text($0) },
            revealTextFieldLabel: { state in
                { type in
                    ForegroundColorImage(
                        image: RevealTextFieldLabel.systemEye(secureFieldType: type),
                        color: revealTextFieldLabelColorSet.resolve(state)
                    )
                }
            },
            labelPadding: labelPadding,
            font: font,
            isExternallyFocused: false,
            configuration: .init()
        )
    }
}
