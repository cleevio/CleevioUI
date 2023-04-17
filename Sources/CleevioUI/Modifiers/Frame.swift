//
//  Frame.swift
//  Pods
//
//  Created by Diego on 18/01/22.
//

import SwiftUI

extension View {
    @inlinable
    public func frame(size: CGSize, alignment: Alignment = .center) -> some View {
        frame(width: size.width, height: size.height, alignment: alignment)
    }
}
