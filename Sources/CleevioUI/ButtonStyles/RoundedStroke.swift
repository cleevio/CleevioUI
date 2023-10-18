import SwiftUI

public struct RoundedStroke: View {
    var color: Color
    var cornerRadius: CGFloat
    var lineWidth: CGFloat
    
    public init(
        color: Color,
        cornerRadius: CGFloat,
        lineWidth: CGFloat = 1
    ) {
        self.color = color
        self.cornerRadius = cornerRadius
        self.lineWidth = lineWidth
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(color, lineWidth: lineWidth)
    }
}
