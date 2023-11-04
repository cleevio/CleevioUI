import SwiftUI

@available(macOS 10.15, *)
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
    
        if #available(iOS 15.0, macOS 12.0, *) {
            return overlay(alignment: alignment, content: { overlayContent })
        } else {
            return overlay(overlayContent, alignment: alignment)
        }
    }

    /// Conditionally overlays a view if a value is non-nil.
    ///
    /// Use this method to overlay a view conditionally based on a value being non-nil. If the provided value is not nil, the content closure is used to create the overlay view, which is then added to the original view.
    ///
    /// - Parameters:
    ///   - ifLet: The value that is conditionally checked for being non-nil.
    ///   - alignment: The alignment of the overlay view within the original view. Default is `.center`.
    ///   - content: A closure that constructs the overlay view using the non-nil value.
    ///
    /// - Returns: A view with the conditional overlay.
    ///
    /// Example:
    /// ```swift
    /// Image(systemName: "star.fill")
    ///     .overlay(ifLet: icon) { icon in
    ///         icon
    ///             .foregroundColor(.yellow)
    ///     }
    /// ```
    @available(macOS 10.15, *)
    @ViewBuilder
    func overlay<V, IfLet>(ifLet: IfLet?, alignment: Alignment = .center, @ViewBuilder content: (IfLet) -> V) -> some View where V: View {
        self.overlay(if: true, alignment: alignment) {
            if let ifLet {
                content(ifLet)
            }
        }
    }
}
