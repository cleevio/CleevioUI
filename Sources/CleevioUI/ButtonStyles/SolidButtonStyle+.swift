import SwiftUI

@available(macOS 10.15, *)
public extension SolidButtonStyle where Background == Color, Overlay == RoundedStroke, LoadingView == CleevioUI.LoadingView {
    @inlinable
    init(
        foregroundColorSet: ButtonStateColorSet,
        backgroundColorSet: ButtonStateColorSet,
        strokeColorSet: ButtonStateColorSet,
        loadingViewColor: Color,
        cornerRadius: CGFloat,
        labelPadding: EdgeInsets,
        font: Font?,
        width: CGFloat? = nil
    ) {
        self.init(
            foreground: foregroundColorSet.color,
            background: backgroundColorSet.color,
            overlay: {
                RoundedStroke(
                    color: strokeColorSet.color(isEnabled: $0, isPressed: $1),
                    cornerRadius: cornerRadius
                )
            },
            loadingView: { LoadingView(circleColor: loadingViewColor) },
            cornerRadius: cornerRadius,
            labelPadding: labelPadding,
            font: font,
            width: width
        )
    }
}
