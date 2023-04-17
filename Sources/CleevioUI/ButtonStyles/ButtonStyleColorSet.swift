//
//  ButtonStyleColorSet.swift
//  
//
//  Created by Lukáš Valenta on 17.04.2023.
//

import SwiftUI

public struct ButtonStyleColorSet {
    public let normal: Color
    public let pressed: Color
    public let disabled: Color

    public init(normal: Color, pressed: Color?, disabled: Color?) {
        self.normal = normal
        self.pressed = pressed ?? normal.opacity(0.8)
        self.disabled = disabled ?? normal.opacity(0.2)
    }

    public func color(isEnabled: Bool, isPressed: Bool) -> Color {
        guard isEnabled else { return disabled }
        return isPressed ? pressed : normal
    }
}
