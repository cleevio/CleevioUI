//
//  LoadingView.swift
//  CleevioUI
//
//  Created by Diego on 10/01/22.
//

import Foundation
import SwiftUI

@available(macOS 10.15, *)
public struct DotProgressViewStyle: ProgressViewStyle {
    var scale: CGFloat
    var spacing: CGFloat
    var dotDiameter: CGFloat
    var dotCount: Int
    var circleColor: Color

    private var calculatedWidth: CGFloat { (CGFloat(dotCount) * dotDiameter) + (CGFloat(dotCount - 1) * spacing) }
    private let animationDuration: CGFloat = 0.5

    @State private var isAnimating: Bool = false

    public init(scale: CGFloat = 1,
                spacing: CGFloat = 10,
                dotDiameter: CGFloat = 10,
                dotCount: Int = 3,
                circleColor: Color = .white) {
        self.scale = scale
        self.spacing = spacing
        self.dotDiameter = dotDiameter
        self.dotCount = dotCount
        self.circleColor = circleColor
    }

    public func makeBody(configuration: Configuration) -> some View {
        let calculatedWidth = self.calculatedWidth

        VStack {
            HStack(spacing: spacing) {
                ForEach(0 ..< dotCount, id: \.self) { index in
                    Circle()
                        .foregroundColor(circleColor)
                        .opacity(isAnimating ? 0.2 : 1)
                        .animation(
                            Animation
                                .easeInOut(duration: animationDuration)
                                .repeatForever(autoreverses: true)
                                .delay(animationDuration * (Double(index) / Double(dotCount)))
                        )
                }
            }
            .frame(width: calculatedWidth, height: dotDiameter, alignment: .center)
            .scaleEffect(.init(scale))
            .frame(minWidth: calculatedWidth, maxWidth: .infinity, minHeight: dotDiameter, maxHeight: .infinity)
            .onAppear {
                if !isAnimating {
                    isAnimating = true
                }
            }
        }
    }
}

@available(iOS 14.0, macOS 11.0, *)
public extension ProgressViewStyle where Self == DotProgressViewStyle {
    static var dot: Self { .dot() }

    static func dot(scale: CGFloat = 1,
                    spacing: CGFloat = 10,
                    dotDiameter: CGFloat = 10,
                    dotCount: Int = 3,
                    circleColor: Color = .white) -> Self {
        .init(
            scale: scale,
            spacing: spacing,
            dotDiameter: dotDiameter,
            dotCount: dotCount,
            circleColor: circleColor
        )
    }
    
}

@available(iOS 15.0, macOS 12.0, *)
struct DotProgressViewStyle_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView()
            .progressViewStyle(.dot(circleColor: .black))
    }
}
