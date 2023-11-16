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
@available(iOS 15.0, *)
public struct IsLoadingPrimitiveButtonStyle<ProgressView: View>: PrimitiveButtonStyle {
    
    /// Environment variable to track loading state.
    @Environment(\.isLoading) private var isLoading
    
    /// The progress view to display when loading is true.
    public var progressView: ProgressView
    
    /// Initializes the IsLoadingPrimitiveButtonStyle with a progress view.
    /// - Parameter progressView: A closure returning the progress view to be used.
    @inlinable
    public init(@ViewBuilder progressView: () -> (ProgressView)) {
        self.progressView = progressView()
    }

    /// Creates the body of the button with loading state handling.
    /// - Parameter configuration: The button's configuration.
    /// - Returns: A modified button view based on loading state.
    public func makeBody(configuration: PrimitiveButtonStyleConfiguration) -> some View {
        Button(configuration)
            .disabled(isLoading)
            .overlay {
                if isLoading {
                    progressView
                }
            }
    }
}

/// A default progress view for use with IsLoadingPrimitiveButtonStyle.
@available(iOS 15.0, *)
public struct DefaultPrimitiveButtonProgressView<Shape: SwiftUI.Shape, BackgroundStyle: SwiftUI.ShapeStyle, ForegroundStyle: SwiftUI.ShapeStyle>: View {
    
    /// The configuration for the progress view.
    public let configuration: Configuration
    
    /// Initializes the DefaultPrimitiveButtonProgressView with a configuration.
    /// - Parameter configuration: The configuration for the progress view.
    @inlinable
    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public var body: some View {
        ProgressView()
            .padding(configuration.padding)
            .background(configuration.background)
            .clipShape(configuration.clipShape)
            .foregroundStyle(configuration.foregroundStyle)
    }
    
    /// Configuration for the DefaultPrimitiveButtonProgressView.
    public struct Configuration {
        public let padding: EdgeInsets
        public let background: BackgroundStyle
        public let clipShape: Shape
        public let foregroundStyle: ForegroundStyle

        /// Initializes the Configuration with specified parameters.
        /// - Parameters:
        ///   - padding: The padding around the progress view.
        ///   - background: The background style of the progress view.
        ///   - clipShape: The clip shape applied to the progress view.
        ///   - foregroundStyle: The foreground style of the progress view.
        @inlinable
        public init(padding: EdgeInsets, background: BackgroundStyle, clipShape: Shape, foregroundStyle: ForegroundStyle) {
            self.padding = padding
            self.background = background
            self.clipShape = clipShape
            self.foregroundStyle = foregroundStyle
        }
    }
}

@available(iOS 15.0, *)
public extension DefaultPrimitiveButtonProgressView<Circle, Material, HierarchicalShapeStyle> {
    
    /// Initializes the DefaultPrimitiveButtonProgressView with default parameters.
    @inlinable
    init() { self.init(configuration: .init()) }
}

@available(iOS 15.0, *)
public extension DefaultPrimitiveButtonProgressView<Circle, Material, HierarchicalShapeStyle>.Configuration {
    
    /// Initializes the Configuration with default parameters.
    /// - Parameters:
    ///   - padding: The padding around the progress view.
    ///   - material: The material background style of the progress view.
    ///   - foregroundStyle: The foreground style of the progress view.
    @inlinable
    init(padding: CGFloat = 2,
         material: Material = .ultraThinMaterial,
         foregroundStyle: HierarchicalShapeStyle = .tertiary) {
        self.init(
            padding: .init(top: padding, leading: padding, bottom: padding, trailing: padding),
            background: material,
            clipShape: Circle(),
            foregroundStyle: foregroundStyle
        )
    }
}

@available(iOS 15.0, *)
public extension PrimitiveButtonStyle where Self == IsLoadingPrimitiveButtonStyle<DefaultPrimitiveButtonProgressView<Circle, Material, HierarchicalShapeStyle>> {
    
    /// A convenience extension providing a pre-configured IsLoadingPrimitiveButtonStyle with a default progress view.
    static var isLoading: Self {
        Self.init(progressView: { DefaultPrimitiveButtonProgressView() })
    }
}
