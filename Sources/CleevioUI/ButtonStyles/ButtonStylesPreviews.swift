import SwiftUI

@available(macOS 10.15, *)
extension ButtonStyle where Self == SolidButtonStyle<Color, RoundedStroke> {
    /// Initializer color sets. It is expected that projects implement their own convenience initializer based on the colors of designer
    static func solid(
        labelTextColorSet: ButtonStateColorSet,
        labelColorSet: ButtonStateColorSet,
        outlineColorSet: ButtonStateColorSet,
        loadingCircleColor: Color? = nil,
        cornerRadius: CGFloat? = nil,
        verticalPadding: CGFloat? = nil,
        horizontalPadding: CGFloat? = nil,
        font: Font? = nil,
        fullWidth: Bool = true
    ) -> Self {
        SolidButtonStyle(
            foregroundColorSet: labelTextColorSet,
            backgroundColorSet: labelColorSet,
            strokeColorSet: outlineColorSet,
            cornerRadius: cornerRadius ?? 8,
            labelPadding: EdgeInsets(
                top: verticalPadding ?? 8,
                leading: horizontalPadding ?? 16,
                bottom: verticalPadding ?? 8,
                trailing: horizontalPadding ?? 16
            ),
            font: font
        )
    }

    /// Initializer that takes all properties. Mostly for debug purposes, it is preferable to use initializer that takes color sets directly.
    static func solid(
        labelTextColor: Color = .white,
        disabledLabelTextColor: Color?,
        pressedLabelTextColor: Color? = nil,
        labelColor: Color,
        pressedLabelColor: Color? = nil,
        disabledLabelColor: Color?,
        labelOutlineColor: Color? = nil,
        pressedLabelOutlineColor: Color? = nil,
        disabledLabelOutlineColor: Color? = nil,
        loadingCircleColor: Color?,
        cornerRadius: CGFloat? = nil,
        verticalPadding: CGFloat? = nil,
        horizontalPadding: CGFloat? = nil,
        font: Font? = nil,
        fullWidth: Bool = true
    ) -> Self {
        solid(
            labelTextColorSet: ButtonStateColorSet(
                normal: labelTextColor,
                pressed: pressedLabelTextColor,
                disabled: disabledLabelTextColor
            ),
            labelColorSet: ButtonStateColorSet(
                normal: labelColor,
                pressed: pressedLabelColor,
                disabled: disabledLabelColor
            ),
            outlineColorSet: ButtonStateColorSet(
                normal: labelOutlineColor ?? labelColor,
                pressed: pressedLabelOutlineColor,
                disabled: disabledLabelOutlineColor
            ),
            loadingCircleColor: loadingCircleColor,
            cornerRadius: cornerRadius,
            verticalPadding: verticalPadding,
            horizontalPadding: horizontalPadding,
            font: font,
            fullWidth: fullWidth
        )
    }
}


@available(iOS 15.0, macOS 11.0, *)
struct SolidButton_Previews: PreviewProvider {
    // swiftlint:disable closure_body_length
    enum SolidPreviewStyle {
        case blue, red, outline

        var labelTextColorSet: ButtonStateColorSet {
            switch self {
            case .blue:
                return ButtonStateColorSet(
                    normal: Color.white,
                    pressed: Color.white,
                    disabled: Color.gray
                )
            case .red:
                return ButtonStateColorSet(
                    normal: Color.white,
                    pressed: Color.white,
                    disabled: Color.white
                )
            case .outline:
                return ButtonStateColorSet(
                    normal: Color.black,
                    pressed: Color.black,
                    disabled: Color.gray
                )
            }
        }

        var labelColorSet: ButtonStateColorSet {
            switch self {
            case .blue:
                return ButtonStateColorSet(
                    normal: Color.blue.opacity(0.95),
                    pressed: Color.blue,
                    disabled: Color.blue.opacity(0.3)
                )
            case .red:
                return ButtonStateColorSet(
                    normal: Color.red.opacity(0.95),
                    pressed: Color.red,
                    disabled: Color.red.opacity(0.3)
                )
            case .outline:
                return ButtonStateColorSet(
                    normal: Color.clear,
                    pressed: Color.gray.opacity(0.2),
                    disabled: Color.gray.opacity(0.3)
                )
            }
        }

        var outlineColorSet: ButtonStateColorSet {
            switch self {
            case .blue, .red:
                return labelColorSet
            case .outline:
                let labelColorSet = self.labelColorSet
                return ButtonStateColorSet(
                    normal: Color.black.opacity(0.3),
                    pressed: Color.black.opacity(0.3),
                    disabled: labelColorSet.disabled
                )
            }
        }

        var loadingCircleColor: Color {
            self == .outline ? .black : .white
        }
    }

        static var previews: some View {
        ForEach([SolidPreviewStyle.blue, .red, .outline], id: \.self) { style in
            VStack(alignment: .leading, spacing: 16) {
                AsyncButton("Large Label isLoading", action: { })
                    .isLoading(true)
                    .buttonStyle(.solid(
                        labelTextColorSet: style.labelTextColorSet,
                        labelColorSet: style.labelColorSet,
                        outlineColorSet: style.outlineColorSet,
                        loadingCircleColor: style.loadingCircleColor,
                        verticalPadding: 12,
                        horizontalPadding: 20,
                        fullWidth: false
                    ))

                Button("Large Label full width", action: { })
                    .buttonStyle(.solid(
                        labelTextColorSet: style.labelTextColorSet,
                        labelColorSet: style.labelColorSet,
                        outlineColorSet: style.outlineColorSet,
                        verticalPadding: 12,
                        horizontalPadding: 20,
                        fullWidth: true
                    ))

                Button("Large Label", action: { })
                    .buttonStyle(.solid(
                        labelTextColorSet: style.labelTextColorSet,
                        labelColorSet: style.labelColorSet,
                        outlineColorSet: style.outlineColorSet,
                        verticalPadding: 12,
                        horizontalPadding: 20,
                        fullWidth: false
                    ))

                Button(action: { },
                       label: { Text("Medium label") })
                .buttonStyle(.solid(
                    labelTextColorSet: style.labelTextColorSet,
                    labelColorSet: style.labelColorSet,
                    outlineColorSet: style.outlineColorSet,
                    fullWidth: false
                ))

                Button(action: { },
                       label: { Text("Medium Label full width") })
                .buttonStyle(.solid(
                    labelTextColorSet: style.labelTextColorSet,
                    labelColorSet: style.labelColorSet,
                    outlineColorSet: style.outlineColorSet,
                    fullWidth: true
                ))

                Button(action: { },
                       label: {
                    Label("Medium label  with image", systemImage: "arrow.left")
                })
                .buttonStyle(.solid(
                    labelTextColorSet: style.labelTextColorSet,
                    labelColorSet: style.labelColorSet,
                    outlineColorSet: style.outlineColorSet,
                    fullWidth: false
                ))

                Button(action: { },
                       label: { Text("Small Label") })
                .buttonStyle(.solid(
                    labelTextColorSet: style.labelTextColorSet,
                    labelColorSet: style.labelColorSet,
                    outlineColorSet: style.outlineColorSet,
                    verticalPadding: 6,
                    horizontalPadding: 12,
                    fullWidth: false
                ))

                Button(action: { },
                       label: { Text("Small Disabled Label") })
                .buttonStyle(.solid(
                    labelTextColorSet: style.labelTextColorSet,
                    labelColorSet: style.labelColorSet,
                    outlineColorSet: style.outlineColorSet,
                    verticalPadding: 6,
                    horizontalPadding: 12,
                    fullWidth: false
                ))
                .disabled(true)
            }
            .padding()
            .previewDisplayName("\(style)")
            .progressViewStyle(DotProgressViewStyle(circleColor: style == .outline ? .black : .white))
        }
    }
}

