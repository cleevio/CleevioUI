//
//  AccessibilityContext.swift
//  
//
//  Created by Vendula Švastalová on 23.03.2023.
//

import SwiftUI

// MARK: - Environment keys

public struct AccessibilityContextKey: EnvironmentKey {
    public static var defaultValue: String?
}

@available(macOS 10.15, *)
extension EnvironmentValues {
    @inlinable
    var accessibilityContext: String? {
        get { self[AccessibilityContextKey.self] }
        set { self[AccessibilityContextKey.self] = newValue }
    }
}

@available(macOS 10.15, *)
public extension View {
    /// Adds `context` to the `Environment` that is read and used within `addToAccessibilityContext()`
    @inlinable
    func accessibilityContext(_ value: String?) -> some View {
        environment(\.accessibilityContext, value)
    }
}
