//
//  ContextAccessibilityIdentifierModifier.swift
//  
//
//  Created by Vendula Švastalová on 23.03.2023.
//

import SwiftUI

@available(iOS 14.0, macOS 11.0, *)
public struct ContextAccessibilityIdentifierModifier: ViewModifier {
    @usableFromInline
    let identifier: AccessibilityIdentifier

    @usableFromInline
    init(identifier: AccessibilityIdentifier) {
        self.identifier = identifier
    }

    @Environment(\.accessibilityContext) private var accessibilityContext: String?

    public func body(content: Content) -> some View {
        content
            .accessibilityIdentifier(
                [accessibilityContext, identifier.description]
                    .compactMap { $0 }
                    .joined(separator: ".")
            )
    }
}

@available(iOS 14.0, macOS 11.0, *)
public struct ContextAccessibilityModifier: ViewModifier {
    @usableFromInline
    let context: String

    @usableFromInline
    init(context: String) {
        self.context = context
    }

    @Environment(\.accessibilityContext) private var accessibilityContext: String?

    public func body(content: Content) -> some View {
        content
            .accessibilityContext(
                [accessibilityContext, context]
                    .compactMap { $0 }
                    .joined(separator: ".")
            )
    }
}

@available(macOS 10.15, *)
public extension View {
    /// Sets SwiftUI `accessibilityIdentifier` composed from `AccessibilityContext` if any is present and the given `AccessibilityIdentifier`.
    @available(iOS 14.0, macOS 11.0, *)
    @inlinable
    func addToAccessibilityContext(identifier: AccessibilityIdentifier) -> some View {
        modifier(ContextAccessibilityIdentifierModifier(identifier: identifier))
    }

    /// Sets SwiftUI `accessibilityContext` composed from `AccessibilityContext` if any is present and the given `AccessibilityContext`.
    @available(iOS 14.0, macOS 11.0, *)
    @inlinable
    func addToAccessibilityContext(context: String) -> some View {
        modifier(ContextAccessibilityModifier(context: context))
    }
}
