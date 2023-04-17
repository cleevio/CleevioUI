//
//  ViewWidth.swift
//  CleevioUI
//
//  Created by Diego on 10/01/22.
//

import Foundation
import SwiftUI

public extension View {
    @inlinable
    func fullWidth(_ isTrue: Bool) -> some View {
        frame(maxWidth: isTrue ? .infinity : nil)
    }
}
