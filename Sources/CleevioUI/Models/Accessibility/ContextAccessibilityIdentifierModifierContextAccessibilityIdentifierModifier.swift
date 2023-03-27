//
//  ContextAccessibilityIdentifierModifier.swift
//  
//
//  Created by Vendula Švastalová on 23.03.2023.
//

import SwiftUI

@available(iOS 14.0, *)
struct ContextAccessibilityIdentifierModifier: ViewModifier {
    let identifier: AccessibilityIdentifier
    
    @Environment(\.accessibilityContext) private var accessibilityContext: String?
    
    func body(content: Content) -> some View {
        content
            .accessibilityIdentifier(
                [accessibilityContext, identifier.description]
                    .compactMap { $0 }
                    .joined(separator: ".")
            )
    }
}

public extension View {
    /// Sets SwiftUI `accessibilityIdentifier` composed from `AccessibilityContext` if any is present and the given `AccessibilityIdentifier`.
    @available(iOS 14.0, *)
    func addToAccessibilityContext(identifier: AccessibilityIdentifier) -> some View {
        modifier(ContextAccessibilityIdentifierModifier(identifier: identifier))
    }
}
