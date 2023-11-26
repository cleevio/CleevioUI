import SwiftUI

// TODO: Use ProgressViewStyle for loading view (or completely erase it from init and just have it being set on the project)

/// A custom button style that allows you to define the appearance of a button with various states and loading view.
@available(macOS 10.15, *)
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
    @usableFromInline
    @ViewBuilder var foreground: (Bool, Bool) -> Color
    ///  Defines the background view for different button states.
    ///
    /// - Parameters:
    ///   - isEnabled: A boolean indicating whether the button is enabled.
    ///   - isPressed: A boolean indicating whether the button is currently pressed.
    ///
    /// - Returns: The background view for the button.
    @usableFromInline
    @ViewBuilder var background: (Bool, Bool) -> Background
    /// Defines the overlay view for different button states.
    ///
    /// - Parameters:
    ///   - isEnabled: A boolean indicating whether the button is enabled.
    ///   - isPressed: A boolean indicating whether the button is currently pressed.
    ///
    /// - Returns: The overlay view for the button.
    @usableFromInline
    @ViewBuilder var overlay: (Bool, Bool) -> Overlay
    // The view used as a loading indicator.
    @usableFromInline
    let loadingView: LoadingView
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
            .disabled(isLoading)
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
