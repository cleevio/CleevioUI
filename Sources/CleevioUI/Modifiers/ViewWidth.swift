//
//  ViewWidth.swift
//  CleevioUI
//
//  Created by Diego on 10/01/22.
//

import Foundation
import SwiftUI

@available(macOS 10.15, *)
public extension View {
    @inlinable
    func fullWidth(_ isTrue: Bool) -> some View {
        frame(maxWidth: isTrue ? .infinity : nil)
    }
}
