//
//  ButtonStateColorSet.swift
//  
//
//  Created by Lukáš Valenta on 17.04.2023.
//

import SwiftUI

/// A set of colors representing different states of a button.
@available(macOS 10.15, *)
public struct ButtonStateColorSet {
    /// The color for the normal (enabled and not pressed) state of the button.
    public let normal: Color
    /// The color for the pressed (tapped) state of the button.
    public let pressed: Color
    /// The color for the disabled state of the button.
    public let disabled: Color

    /// Initializes a ButtonStateColorSet with color values for different states.
    ///
    /// - Parameters:
    ///   - normal: The color for the normal state of the button.
    ///   - pressed: The color for the pressed state of the button (optional, defaults to 80% opacity of normal color).
    ///   - disabled: The color for the disabled state of the button (optional, defaults to 20% opacity of normal color).
    public init(normal: Color, pressed: Color?, disabled: Color?) {
        self.normal = normal
        self.pressed = pressed ?? normal.opacity(0.8)
        self.disabled = disabled ?? normal.opacity(0.2)
    }

    /// Returns the appropriate color based on the button's state.
    ///
    /// - Parameters:
    ///   - isEnabled: A boolean indicating whether the button is enabled.
    ///   - isPressed: A boolean indicating whether the button is currently pressed.
    ///
    /// - Returns: The color to use based on the button's state (normal, pressed, or disabled).
    public func color(state: StateButtonState) -> Color {
        guard state.isEnabled else { return disabled }
        return state.isPressed ? pressed : normal
    }
}
