import SwiftUI

public extension View {
    /// Adds an overlay to the view if a specified condition is met.
    ///
    /// - Parameters:
    ///   - condition: A boolean condition that determines whether the overlay should be added.
    ///   - alignment: The alignment of the overlay content within the view.
    ///   - content: A closure that defines the content of the overlay, which is only added if the condition is `true`.
    ///
    /// - Returns: A modified view with the conditional overlay.
    ///
    /// - Note: If `condition` is `true`, the `content` view will be overlaid on top of the original view with the specified `alignment`. If `condition` is `false`, the overlay will not be added, and the original view remains unchanged.
    func overlay<V>(if condition: Bool, alignment: Alignment = .center, @ViewBuilder content: () -> V) -> some View where V : View {
        @ViewBuilder
        var overlayContent: some View {
            if condition {
                content()
            }
        }
    
        if #available(iOS 15.0, *) {
            return overlay(alignment: alignment, content: { overlayContent })
        } else {
            return overlay(overlayContent, alignment: alignment)
        }
    }
}
