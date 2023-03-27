//
//  AccessibilityContext.swift
//  
//
//  Created by Vendula Švastalová on 23.03.2023.
//

import SwiftUI

// MARK: - Environment keys

struct AccessibilityContextKey: EnvironmentKey {
    public static var defaultValue: String?
}

extension EnvironmentValues {
    var accessibilityContext: String? {
        get { self[AccessibilityContextKey.self] }
        set { self[AccessibilityContextKey.self] = newValue }
    }
}

public extension View {
    /// Adds `context` to the `Environment` that is read and used within `addToAccessibilityContext()`
    func accessibilityContext(_ value: String?) -> some View {
        environment(\.accessibilityContext, value)
    }
}
