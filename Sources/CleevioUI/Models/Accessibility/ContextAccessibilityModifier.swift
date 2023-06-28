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

@available(iOS 14.0, *)
struct ContextAccessibilityModifier: ViewModifier {
    let context: String
    
    @Environment(\.accessibilityContext) private var accessibilityContext: String?
    
    func body(content: Content) -> some View {
        content
            .accessibilityContext(
                [accessibilityContext, context]
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

    /// Sets SwiftUI `accessibilityContext` composed from `AccessibilityContext` if any is present and the given `AccessibilityContext`.
    @available(iOS 14.0, *)
    func addToAccessibilityContext(context: String) -> some View {
        modifier(ContextAccessibilityModifier(context: context))
    }
}
