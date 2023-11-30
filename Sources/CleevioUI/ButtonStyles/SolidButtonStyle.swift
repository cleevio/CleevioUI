import SwiftUI

// TODO: Use ProgressViewStyle for loading view (or completely erase it from init and just have it being set on the project)

public struct SolidButtonState {
    public let isLoading: Bool
    public let isEnabled: Bool
    public let isPressed: Bool

    @inlinable
    public init(isLoading: Bool, isEnabled: Bool, isPressed: Bool) {
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.isPressed = isPressed
    }
}

/// A custom button style that allows you to define the appearance of a button with various states and loading view.
@available(macOS 10.15, *)
public struct SolidButtonStyle<
    Background: View,
    Overlay: View
>: ButtonStyle {

    /// Defines the text color for different button states.
    ///
    /// - Parameters:
    ///   - isEnabled: A boolean indicating whether the button is enabled.
    ///   - isPressed: A boolean indicating whether the button is currently pressed.
    ///
    /// - Returns: The color to use for the button's text.
    @usableFromInline
    @ViewBuilder var foreground: (SolidButtonState) -> Color
    ///  Defines the background view for different button states.
    ///
    /// - Parameters:
    ///   - isEnabled: A boolean indicating whether the button is enabled.
    ///   - isPressed: A boolean indicating whether the button is currently pressed.
    ///
    /// - Returns: The background view for the button.
    @usableFromInline
    @ViewBuilder var background: (SolidButtonState) -> Background
    /// Defines the overlay view for different button states.
    ///
    /// - Parameters:
    ///   - isEnabled: A boolean indicating whether the button is enabled.
    ///   - isPressed: A boolean indicating whether the button is currently pressed.
    ///
    /// - Returns: The overlay view for the button.
    @usableFromInline
    @ViewBuilder var overlay: (SolidButtonState) -> Overlay
    // The view used as a loading indicator.
    /// The corner radius of the button.
    @usableFromInline
    let cornerRadius: CGFloat
    /// Padding for the button's label.
    @usableFromInline
    let labelPadding: EdgeInsets
    /// Optional width for the button.
    @usableFromInline
    let width: CGFloat?
    /// Optional font for the button's label.
    @usableFromInline
    let font: Font?

    @inlinable
    public init(
        @ViewBuilder foreground: @escaping (SolidButtonState) -> Color,
        @ViewBuilder background: @escaping (SolidButtonState) -> Background,
        @ViewBuilder overlay: @escaping (SolidButtonState) -> Overlay,
        cornerRadius: CGFloat,
        labelPadding: EdgeInsets,
        font: Font?,
        width: CGFloat?
    ) {
        self.foreground = foreground
        self.background = background
        self.overlay = overlay
        self.cornerRadius = cornerRadius
        self.labelPadding = labelPadding
        self.font = font
        self.width = width
    }

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isLoading) private var isLoading
    

    public func makeBody(configuration: Configuration) -> some View {
        let buttonState = SolidButtonState(isLoading: isLoading, isEnabled: isEnabled, isPressed: configuration.isPressed)

        configuration.label
            .disabled(isLoading)
            .frame(maxWidth: width)
            .padding(labelPadding)
            .background(background(buttonState))
            .foregroundColor(foreground(buttonState))
            .overlay(overlay(buttonState))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .contentShape(Rectangle())
            .font(font)
    }
}
