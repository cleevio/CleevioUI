//
//  SwiftUIView.swift
//  
//
//  Created by Lukáš Valenta on 17.04.2023.
//

import SwiftUI

public struct LoadingKey: EnvironmentKey {
    public static var defaultValue: Bool = false
}

public extension EnvironmentValues {
    var isLoading: Bool {
        get { self[LoadingKey.self] }
        set { self[LoadingKey.self] = newValue }
    }
}

public extension View {
    @inlinable
    func isLoading(_ isLoading: Bool) -> some View {
        environment(\.isLoading, isLoading)
    }
}
