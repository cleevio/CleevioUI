import SwiftUI

/// A custom button style that allows you to define the appearance of a button with various states and loading view.
public struct SolidButtonStyle<
    Background: View,
    Overlay: View,
    LoadingView: View
>: ButtonStyle {
    /// Defines the text color for different button states.
    ///
    /// - Parameters:
    ///   - isEnabled: A boolean indicating whether the button is enabled.
    ///   - isPressed: A boolean indicating whether the button is currently pressed.
    ///
    /// - Returns: The color to use for the button's text.
    @ViewBuilder var foreground: (Bool, Bool) -> Color
    ///  Defines the background view for different button states.
    ///
    /// - Parameters:
    ///   - isEnabled: A boolean indicating whether the button is enabled.
    ///   - isPressed: A boolean indicating whether the button is currently pressed.
    ///
    /// - Returns: The background view for the button.
    @ViewBuilder var background: (Bool, Bool) -> Background
    /// Defines the overlay view for different button states.
    ///
    /// - Parameters:
    ///   - isEnabled: A boolean indicating whether the button is enabled.
    ///   - isPressed: A boolean indicating whether the button is currently pressed.
    ///
    /// - Returns: The overlay view for the button.
    @ViewBuilder var overlay: (Bool, Bool) -> Overlay
    // The view used as a loading indicator.
    let loadingView: LoadingView
    /// The corner radius of the button.
    let cornerRadius: CGFloat
    /// Padding for the button's label.
    let labelPadding: EdgeInsets
    /// Optional width for the button.
    let width: CGFloat?
    /// Optional font for the button's label.
    let font: Font?

    public init(
        @ViewBuilder foreground: @escaping (Bool, Bool) -> Color,
        @ViewBuilder background: @escaping (Bool, Bool) -> Background,
        @ViewBuilder overlay: @escaping (Bool, Bool) -> Overlay,
        @ViewBuilder loadingView: () -> LoadingView,
        cornerRadius: CGFloat,
        labelPadding: EdgeInsets,
        font: Font?,
        width: CGFloat?
    ) {
        self.foreground = foreground
        self.background = background
        self.overlay = overlay
        self.loadingView = loadingView()
        self.cornerRadius = cornerRadius
        self.labelPadding = labelPadding
        self.font = font
        self.width = width
    }

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isLoading) private var isLoading

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .disabled(!isEnabled || isLoading)
            .frame(maxWidth: width)
            .padding(labelPadding)
            .background(background(isEnabled, configuration.isPressed))
            .foregroundColor(isLoading ? .clear : foreground(isEnabled, configuration.isPressed))
            .overlay(overlay(isEnabled, configuration.isPressed))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .contentShape(Rectangle())
            .font(font)
            .overlay(if: isLoading) {
                loadingView
            }
    }
}