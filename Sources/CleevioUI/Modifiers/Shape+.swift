//
//  Shape+.swift
//  Pods
//
//  Created by Diego on 25/01/22.
//

import SwiftUI

@available(macOS 10.15, *)
extension Shape {
    @inlinable
    public func style<StrokeContent: ShapeStyle, FillContent: ShapeStyle>(
        withStroke strokeContent: StrokeContent,
        lineWidth: CGFloat = 1,
        fill fillContent: FillContent
    ) -> some View {
        self.stroke(strokeContent, lineWidth: lineWidth)
            .background(fill(fillContent))
    }
}
