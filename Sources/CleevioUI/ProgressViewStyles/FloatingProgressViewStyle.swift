//
//  FloatingProgressViewStyle.swift
//
//
//  Created by Lukáš Valenta on 26.11.2023.
//

import SwiftUI

@available(macOS 12.0, iOS 15.0, *)
public struct FloatingProgressViewStyle<
    Shape: SwiftUI.Shape,
    BackgroundStyle: SwiftUI.ShapeStyle,
    ForegroundStyle: SwiftUI.ShapeStyle
>: ProgressViewStyle {
    /// The configuration for the progress view.
    public let configuration: StyleConfiguration
    
    /// Initializes the DefaultPrimitiveButtonProgressView with a configuration.
    /// - Parameter configuration: The configuration for the progress view.
    @inlinable
    public init(configuration: StyleConfiguration) {
        self.configuration = configuration
    }

    /// Configuration for the DefaultPrimitiveButtonProgressView.
    public struct StyleConfiguration {
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

    public func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration)
            .padding(self.configuration.padding)
            .background(self.configuration.background)
            .clipShape(self.configuration.clipShape)
            .foregroundStyle(self.configuration.foregroundStyle)
    }
}

@available(macOS 12.0, iOS 15.0, watchOS 10, *)
public extension ProgressViewStyle where Self == FloatingProgressViewStyle<Circle, Material, HierarchicalShapeStyle> {
    
    /// Initializes the FloatingProgressViewStyle with default parameters.
    @inlinable
    static var floating: Self { self.init() }
}

@available(macOS 12.0, iOS 15.0, watchOS 10, *)
public extension FloatingProgressViewStyle<Circle, Material, HierarchicalShapeStyle> {
    
    /// Initializes the FloatingProgressViewStyle with default parameters.
    @inlinable
    init() { self.init(configuration: .init()) }
}

@available(macOS 12.0, iOS 15.0, watchOS 10, *)
public extension FloatingProgressViewStyle<Circle, Material, HierarchicalShapeStyle>.StyleConfiguration {
    
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

@available(iOS 15.0, macOS 12.0, watchOS 10, *)
struct FloatingProgressViewStyle_Previews: PreviewProvider {
    static var previews: some View {
        Color.red
            .overlay {
                ProgressView()
                    .progressViewStyle(.floating)
            }
    }
}
