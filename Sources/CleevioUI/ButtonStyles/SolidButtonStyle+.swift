import SwiftUI

@available(macOS 10.15, *)
public extension StateButtonStyle where Background == Color, Overlay == RoundedStroke {
    @inlinable
    init(
        foregroundColorSet: ButtonStateColorSet,
        backgroundColorSet: ButtonStateColorSet,
        strokeColorSet: ButtonStateColorSet,
        cornerRadius: CGFloat,
        labelPadding: EdgeInsets,
        font: Font?,
        width: CGFloat? = nil
    ) {
        self.init(
            foreground: { state in
                state.isLoading ? .clear : foregroundColorSet.color(state: state)
            },
            background: backgroundColorSet.color,
            overlay: { state in
                RoundedStroke(
                    color: strokeColorSet.color(state: state),
                    cornerRadius: cornerRadius
                )
            },
            cornerRadius: cornerRadius,
            labelPadding: labelPadding,
            font: font,
            width: width
        )
    }
}
