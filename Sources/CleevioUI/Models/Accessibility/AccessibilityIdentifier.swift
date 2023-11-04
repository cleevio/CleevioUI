//
//  AccessibilityIdentifier.swift
//  
//
//  Created by Lukáš Valenta on 15.03.2023.
//

import SwiftUI

/// Accessibility identifier structure that contains the most used UI types
/// Uses cases for types of the content that have associatedValue – String – that should be unique per scene.
public enum AccessibilityIdentifier: CustomStringConvertible {
    case text(String)
    case title(String)
    case subtitle(String)
    
    case image(String)
    case button(String)
    case textfield(String)
    case label(String)
    case toggle(String)
    case picker(String)
    
    public var description: String {
        switch self {
        case .button(let string),
                .text(let string),
                .title(let string),
                .image(let string),
                .subtitle(let string),
                .textfield(let string),
                .label(let string),
                .toggle(let string),
                .picker(let string):
            return "\(typeString).\(string)"
        }
    }

    private var typeString: String {
        switch self {
        case .button:
            return "button"
        case .text:
            return "text"
        case .title:
            return "title"
        case .image:
            return "image"
        case .subtitle:
            return "subtitle"
        case .textfield:
            return "textfield"
        case .label:
            return "label"
        case .toggle:
            return "toggle"
        case .picker:
            return "picker"
        }
    }
}

@available(macOS 10.15, *)
public extension View {
    /// SwiftUI view identifier that adds only accessibilityIdentifier which doesn't influence the View any other way
    @available(iOS 14.0, macOS 11.0, *)
    func accessibilityIdentifier(_ identifier: AccessibilityIdentifier) -> some View {
        accessibilityIdentifier(identifier.description)
    }
}

#if canImport(UIKit)
public extension UIView {
    @inlinable
    func withAccessibilityIdentifier(_ identifier: AccessibilityIdentifier) -> Self {
        setAccessibilityIdentifier(identifier)
        return self
    }

    @inlinable
    func setAccessibilityIdentifier(_ identifier: AccessibilityIdentifier) {
        self.accessibilityIdentifier = identifier.description
    }
}
#endif
