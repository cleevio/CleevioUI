import SwiftUI

/// Defines a set of colors for checkbox states.
@available(macOS 10.15, *)
public struct CheckBoxStateColorSet {
    /// Color for the "on" state.
    public let on: Color
    /// Color for the "off" state.
    public let off: Color

    /// A closure to resolve the color based on the checkbox state.
    public var resolve: (Bool) -> Color

    /// Initializes a CheckBoxStateColorSet with specified colors and a resolution closure.
    ///
    /// - Parameters:
    ///   - on: Color for the "on" state.
    ///   - off: Color for the "off" state.
    ///   - resolve: A closure to resolve the color based on the checkbox state.
    public init(on: Color, off: Color, resolve: @escaping (Bool) -> Color) {
        self.on = on
        self.off = off
        self.resolve = resolve
    }

    /// Initializes a CheckBoxStateColorSet with specified colors and a default resolution closure.
    ///
    /// - Parameters:
    ///   - on: Color for the "on" state.
    ///   - off: Color for the "off" state.
    public init(on: Color, off: Color) {
        self.init(on: on, off: off, resolve: { $0 ? on : off })
    }

    /// Initializes a CheckBoxStateColorSet with a single color for both states.
    ///
    /// - Parameter color: Color for both "on" and "off" states.
    public init(_ color: Color) {
        self.init(on: color, off: color)
    }
}
