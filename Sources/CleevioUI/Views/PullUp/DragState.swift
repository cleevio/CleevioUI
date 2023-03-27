//
//  DragState.swift
//  CleevioUI
//
//  Created by Daniel Fernandez on 2/15/21.
//

import SwiftUI

public enum DragState {
    case inactive
    case dragging(translation: CGSize)

    public var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }

    public var isDragging: Bool {
        switch self {
        case .inactive:
            return false
        case .dragging:
            return true
        }
    }
}