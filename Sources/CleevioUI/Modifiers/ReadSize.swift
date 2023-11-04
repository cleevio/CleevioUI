//
//  ReadSize.swift
//  Pods
//
//  Created by Diego on 18/01/22.
//

import SwiftUI

@available(macOS 10.15, *)
extension View {
    @inlinable
    public func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { metrics in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: metrics.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

public struct SizePreferenceKey: PreferenceKey {
    public static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}

    public static var defaultValue: CGSize = .zero
}
