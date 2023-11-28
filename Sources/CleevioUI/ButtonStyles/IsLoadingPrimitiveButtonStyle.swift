//
//  IsLoadingPrimitiveButtonStyle.swift
//
//
//  Created by Lukáš Valenta on 16.11.2023.
//

import Foundation
import SwiftUI

/// A simple PrimitiveButtonStyle that displays a button with loading state handling.
/// When isLoading is set to true, the button is disabled and overlays a progress view.
/// To configure progressView, all it takes is to add a modifier for progressView
@available(iOS 15.0, *)
public struct IsLoadingPrimitiveButtonStyle: PrimitiveButtonStyle {
    
    /// Environment variable to track loading state.
    @Environment(\.isLoading) private var isLoading
    
    /// Initializes the IsLoadingPrimitiveButtonStyle with a progress view.
    /// - Parameter progressView: A closure returning the progress view to be used.
    @inlinable
    public init() { }
    
    /// Creates the body of the button with loading state handling.
    /// - Parameter configuration: The button's configuration.
    /// - Returns: A modified button view based on loading state.
    public func makeBody(configuration: PrimitiveButtonStyleConfiguration) -> some View {
        Button(configuration)
            .disabled(isLoading)
            .overlay {
                if isLoading {
                    ProgressView()
                }
            }
    }
}

@available(iOS 15.0, *)
public extension PrimitiveButtonStyle where Self == IsLoadingPrimitiveButtonStyle {
    
    /// A simple PrimitiveButtonStyle that displays a button with loading state handling.
    /// When isLoading is set to true, the button is disabled and overlays a progress view.
    static var isLoading: Self { self.init() }
}

@available(iOS 15.0, macOS 11.0, *)
struct PrimitiveButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        AsyncButton("Test async button style") {
            print("Doing activity")
            try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 5)
        }
        .buttonStyle(.isLoading)
    }
}
