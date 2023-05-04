//
//  SolidButtonStyle.swift
//  
//
//  Created by Lukáš Valenta on 17.04.2023.
//

import SwiftUI

public struct SolidButtonStyle: ButtonStyle {
    public init(labelTextColorSet: ButtonStyleColorSet, labelColorSet: ButtonStyleColorSet, outlineColorSet: ButtonStyleColorSet, loadingCircleColor: Color, cornerRadius: CGFloat, verticalPadding: CGFloat, horizontalPadding: CGFloat, font: Font? = nil, fullWidth: Bool) {
        self.labelTextColorSet = labelTextColorSet
        self.labelColorSet = labelColorSet
        self.outlineColorSet = outlineColorSet
        self.loadingCircleColor = loadingCircleColor
        self.cornerRadius = cornerRadius
        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
        self.font = font
        self.fullWidth = fullWidth
    }
    
    let labelTextColorSet: ButtonStyleColorSet
    let labelColorSet: ButtonStyleColorSet
    let outlineColorSet: ButtonStyleColorSet
    let loadingCircleColor: Color

    let cornerRadius: CGFloat
    let verticalPadding: CGFloat
    let horizontalPadding: CGFloat
    let font: Font?
    let fullWidth: Bool

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isLoading) private var isLoading

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
           
            .disabled(!isEnabled || isLoading)
            .frame(
                maxWidth: fullWidth ? .infinity : nil
            )
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .background(labelColorSet.color(
                isEnabled: isEnabled,
                isPressed: configuration.isPressed
            ))
            .foregroundColor(isLoading ? .clear : labelTextColorSet.color(
                isEnabled: isEnabled,
                isPressed: configuration.isPressed
            ))
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(outlineColorSet.color(
                        isEnabled: isEnabled,
                        isPressed: configuration.isPressed
                    ),
                            lineWidth: 1)
            )
            .contentShape(Rectangle())
            .font(font)
            .overlay(loadingView)
    }

    @ViewBuilder private var loadingView: some View {
        if isLoading {
            LoadingView(circleColor: loadingCircleColor)
        }
    }
}

public extension ButtonStyle where Self == SolidButtonStyle {
    /// Initializer color sets. It is expected that projects implement their own convenience initializer based on the colors of designer
    @inlinable
    static func solid(
        labelTextColorSet: ButtonStyleColorSet,
        labelColorSet: ButtonStyleColorSet,
        outlineColorSet: ButtonStyleColorSet,
        loadingCircleColor: Color? = nil,
        cornerRadius: CGFloat? = nil,
        verticalPadding: CGFloat? = nil,
        horizontalPadding: CGFloat? = nil,
        font: Font? = nil,
        fullWidth: Bool = true
    ) -> Self {
        SolidButtonStyle(
            labelTextColorSet: labelTextColorSet,
            labelColorSet: labelColorSet,
            outlineColorSet: outlineColorSet,
            loadingCircleColor: loadingCircleColor ?? .white,
            cornerRadius: cornerRadius ?? 8,
            verticalPadding: verticalPadding ?? 8,
            horizontalPadding: horizontalPadding ?? 16,
            font: font,
            fullWidth: fullWidth
        )
    }

    /// Initializer that takes all properties. Mostly for debug purposes, it is preferable to use initializer that takes color sets directly.
    @inlinable
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
            labelTextColorSet: ButtonStyleColorSet(
                normal: labelTextColor,
                pressed: pressedLabelTextColor,
                disabled: disabledLabelTextColor
            ),
            labelColorSet: ButtonStyleColorSet(
                normal: labelColor,
                pressed: pressedLabelColor,
                disabled: disabledLabelColor
            ),
            outlineColorSet: ButtonStyleColorSet(
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

@available(iOS 14.0, *)
struct SolidButton_Previews: PreviewProvider {
    // swiftlint:disable closure_body_length
    enum SolidPreviewStyle {
        case blue, red, outline
        
        var labelTextColorSet: ButtonStyleColorSet {
            switch self {
            case .blue:
                return ButtonStyleColorSet(
                    normal: Color.white,
                    pressed: Color.white,
                    disabled: Color.gray
                )
            case .red:
                return ButtonStyleColorSet(
                    normal: Color.white,
                    pressed: Color.white,
                    disabled: Color.white
                )
            case .outline:
                return ButtonStyleColorSet(
                    normal: Color.black,
                    pressed: Color.black,
                    disabled: Color.gray
                )
            }
        }

        var labelColorSet: ButtonStyleColorSet {
            switch self {
            case .blue:
                return ButtonStyleColorSet(
                    normal: Color.blue.opacity(0.95),
                    pressed: Color.blue,
                    disabled: Color.blue.opacity(0.3)
                )
            case .red:
                return ButtonStyleColorSet(
                    normal: Color.red.opacity(0.95),
                    pressed: Color.red,
                    disabled: Color.red.opacity(0.3)
                )
            case .outline:
                return ButtonStyleColorSet(
                    normal: Color.clear,
                    pressed: Color.gray.opacity(0.2),
                    disabled: Color.gray.opacity(0.3)
                )
            }
        }

        var outlineColorSet: ButtonStyleColorSet {
            switch self {
            case .blue, .red:
                return labelColorSet
            case .outline:
                let labelColorSet = self.labelColorSet
                return ButtonStyleColorSet(
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
                Button("Large Label isLoading", action: { })
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
        }
    }
}
