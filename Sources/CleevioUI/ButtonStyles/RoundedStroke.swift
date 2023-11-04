import SwiftUI

@available(macOS 10.15, *)
public struct RoundedStroke: View {
    public var color: Color
    public var cornerRadius: CGFloat
    public var lineWidth: CGFloat
    
    @inlinable
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
