//
//  FlowLayout.swift
//
//
//  Created by Lukáš Valenta on 07.12.2023.
//

import Foundation

import SwiftUI

/**
 A custom layout conforming to the `Layout` protocol for arranging subviews in a flow-based manner.

 ## Overview
 The `FlowLayout` struct defines a flow layout that arranges subviews horizontally, flowing to the next row when the available width is exhausted. It allows customization of alignment, spacing between subviews, and provides a cache for optimizing layout calculations.

 ## Properties
 - `alignment`: Specifies the horizontal alignment of the subviews within each row.
 - `spacing`: Specifies the spacing between adjacent subviews.

 ## Methods
 - `makeCache(subviews:) -> Cache`: Creates and returns an initial cache for layout calculations.
 - `sizeThatFits(proposal:subviews:cache:) -> CGSize`: Calculates and returns the size that fits the specified constraints.
 - `placeSubviews(in:proposal:subviews:cache:)`: Positions the subviews within the given bounds using the cached layout information.

 ## Types
 - `CalculatedLayout`: Represents the calculated layout information, including subview frames and the overall size.
 - `CalculatedLayout.Builder`: A helper structure for building the calculated layout based on subview sizes and alignment.

 ## Initializers
 - `init(alignment:spacing:)`: Convenience initializer to create a flow layout with specified alignment and spacing.
 
 ## Note
 - FlowLayout always vertically aligns views in one row to top, this behavior can be considered to be updated later on.
 */
@available(iOS 16.0, macOS 13.0, watchOS 9, *)
public struct FlowLayout: Layout {
    let alignment: HorizontalAlignment
    let spacing: CGFloat

    public init(alignment: HorizontalAlignment  = .center,
                spacing: CGFloat = 2) {
        self.alignment = alignment
        self.spacing = spacing
    }
    
    public typealias Cache = CalculatedLayout
    
    public func makeCache(subviews: Subviews) -> Cache {
        CalculatedLayout(frames: [], size: .zero)
    }

    public struct CalculatedLayout {
        var frames: [CGRect]
        var size: CGSize

        public init(frames: [CGRect], size: CGSize) {
            self.frames = frames
            self.size = size
        }

        /// Builds and returns the calculated layout based on the provided parameters within the `FlowLayout.CalculatedLayout.Builder` type.
        ///
        /// - Returns: A `CalculatedLayout` instance representing the calculated layout information.
        ///
        /// - Example:
        ///   ```swift
        ///   let builder = FlowLayout.CalculatedLayout.Builder(
        ///       subviewSizes: [CGSize(width: 50, height: 30), CGSize(width: 70, height: 40)],
        ///       totalWidth: 200,
        ///       alignment: .center,
        ///       spacing: 8.0
        ///   )
        ///   let calculatedLayout = builder.calculatedLayout()
        ///   ```
        public struct Builder {
            let subviewSizes: [CGSize]
            let totalWidth: Double
            let alignment: HorizontalAlignment
            let spacing: CGFloat

            public init(subviewSizes: [CGSize],
                        totalWidth: Double,
                        alignment: HorizontalAlignment,
                        spacing: CGFloat) {
                self.subviewSizes = subviewSizes
                self.totalWidth = totalWidth
                self.alignment = alignment
                self.spacing = spacing
            }

            struct Row {
                var sizes: [CGSize]
                var totalSize: CGSize
                
                mutating func append(size: CGSize, spacing: CGFloat) {
                    sizes.append(size)
                    totalSize = CGSize(
                        width: totalSize.width + size.width + spacing,
                        height: max(totalSize.height, size.height)
                    )
                }
            }

            /**
             Builds and returns the calculated layout based on the provided parameters.

             - Returns: A `CalculatedLayout` instance representing the calculated layout information.
             */
            public func calculatedLayout() -> CalculatedLayout {
                let (rows, totalUsedWidth) = calculatedRows(from: subviewSizes, totalWidth: totalWidth)
                let (frames, height) = calculatedFrames(for: rows, totalUsedWidth: totalUsedWidth)
                
                return CalculatedLayout(
                    frames: frames,
                    size: CGSize(width: totalUsedWidth, height: height)
                )
            }

            /// Calculates rows and total used width based on the provided subview sizes and total width within the `FlowLayout.CalculatedLayout.Builder` type.
            ///
            /// - Parameters:
            ///   - subviewSizes: An array of CGSize representing the sizes of subviews.
            ///   - totalWidth: The total available width for arranging subviews.
            ///
            /// - Returns: A tuple containing an array of `Row` instances representing rows of subviews and the total used width.
            ///
            /// - Example:
            ///   ```swift
            ///   let subviewSizes = [CGSize(width: 50, height: 30), CGSize(width: 70, height: 40)]
            ///   let totalWidth = 200
            ///   let (rows, totalUsedWidth) = calculatedRows(from: subviewSizes, totalWidth: totalWidth)
            ///   ```
            private func calculatedRows(from subviewSizes: [CGSize], totalWidth: CGFloat) -> (rows: [Row], width: CGFloat) {
                var rows: [Row] = []
                var currentRow = -1
                
                var remainingWidth = totalWidth

                var totalUsedWith: CGFloat = 0
                
                for elementSize in subviewSizes {

                    defer {
                        remainingWidth -= (elementSize.width + spacing)
                    }
                    
                    if remainingWidth - (elementSize.width + spacing) >= 0 && !rows.isEmpty {
                        rows[currentRow].append(size: elementSize, spacing: spacing)
                    } else {
                        totalUsedWith = max(totalUsedWith, rows.last?.totalSize.width ?? 0)
                        currentRow += 1
                        rows.append(Row(
                            sizes: [elementSize],
                            totalSize: elementSize
                        ))
                        remainingWidth = totalWidth
                    }
                }

                totalUsedWith = max(totalUsedWith, rows.last?.totalSize.width ?? 0)
                
                return (rows, totalUsedWith)
            }

            /// Calculates frames and overall height based on the provided rows and total used width within the `FlowLayout.CalculatedLayout.Builder` type.
            ///
            /// - Parameters:
            ///   - rows: An array of `Row` instances representing rows of subviews.
            ///   - totalUsedWidth: The total used width for arranging subviews.
            ///
            /// - Returns: A tuple containing an array of CGRect instances representing frames for subviews and the overall height.
            ///
            /// - Example:
            ///   ```swift
            ///   let rows: [Row] = //... calculated rows
            ///   let totalUsedWidth = 200
            ///   let (frames, height) = calculatedFrames(for: rows, totalUsedWidth: totalUsedWidth)
            ///   ```
            private func calculatedFrames(for rows: [Row], totalUsedWidth: CGFloat) -> (frames: [CGRect], height: CGFloat) {
                var viewFrames: [CGRect] = []
                
                var currentSubviewIndex = 0
                var currentYPositionOfRow: CGFloat = 0

                for index in rows.indices {
                    let row = rows[index]
                    defer {
                        var rowSpacing: CGFloat {
                            index == (rows.endIndex - 1) ? 0 : spacing
                        }

                        currentYPositionOfRow += row.totalSize.height + rowSpacing
                    }

                    let xOrigin = getXOrigin(for: row, totalUsedWidth: totalUsedWidth)

                    var currentXPositionAtRow: CGFloat = xOrigin
                    
                    for size in row.sizes {
                        defer {
                            currentSubviewIndex += 1
                            currentXPositionAtRow += size.width + spacing
                        }

                        let rect = CGRect(
                            x: currentXPositionAtRow,
                            y: currentYPositionOfRow,
                            width: size.width,
                            height: size.height
                        )
                        viewFrames.append(rect)
                    }
                }

                return (viewFrames, currentYPositionOfRow)
            }


            private func getXOrigin(for row: Row, totalUsedWidth: CGFloat) -> CGFloat {
                let unusedWidth = totalUsedWidth - row.totalSize.width
                
                switch alignment {
                case .leading:
                    return 0
#if os(iOS)
                case .listRowSeparatorLeading:
                    return 0
                case .listRowSeparatorTrailing:
                    return unusedWidth
#endif
                    
                case .center:
                    return unusedWidth / 2
                case .trailing:
                    return unusedWidth
                
                default:
                    return 0
                }
            }
        }

        mutating func set(with calculatedLayout: CalculatedLayout) {
            frames = calculatedLayout.frames
            size = calculatedLayout.size
        }
    }
    
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        let width = proposal.replacingUnspecifiedDimensions().width
        let calculatedLayout = calculatedLayout(for: subviews, in: width)
        
        cache.set(with: calculatedLayout)
        
        return calculatedLayout.size
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        if cache.size != bounds.size {
            let calculatedLayout = calculatedLayout(for: subviews, in: bounds.width)
            cache.set(with: calculatedLayout)
        }
        
        for index in subviews.indices {
            let frame = cache.frames[index]
            let position = CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY)
            subviews[index].place(at: position, proposal: ProposedViewSize(frame.size))
        }
    }

    func calculatedLayout(for subviews: Subviews, in totalWidth: CGFloat) -> CalculatedLayout {
        CalculatedLayout.Builder(
            subviewSizes: subviews.map { $0.sizeThatFits(.unspecified)},
            totalWidth: totalWidth,
            alignment: alignment,
            spacing: spacing
        ).calculatedLayout()
    }
}

#if DEBUG
@available(iOS 16.0, macOS 13.0, watchOS 10, *)
struct FlowLayout_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            Text("HStack")
            HStack {
                HStack {
                    Text("dlouhej text")
                }
                .background(Color.red)

                HStack {
                    Text("kr")
                }
                .background(Color.green)

                Color.yellow
            }

            Text("FlowLayout")
            HStack {
                FlowLayout {
                    Text("dlouhej text")
                }
                .background(Color.red)

                HStack {
                    Text("kr")
                }
                .background(Color.green)

                Color.yellow
            }

            let alignments = [SwiftUI.HorizontalAlignment.center, SwiftUI.HorizontalAlignment.leading, SwiftUI.HorizontalAlignment.trailing]
            ForEach(alignments.indices, id: \.self) { index in
                let alignment = alignments[index]
                StatePreview(initial: CGSize.zero) { size in
                    layout(for: alignment)
                        .readSize { readSize in
                            size.wrappedValue = readSize
                        }
                        .background(Color.green)
                        .padding(.all)
                        .background(Color.purple)
                        .padding(.vertical)
//                        .overlay {
//                            Text("width: \(size.wrappedValue.width), height: \(size.wrappedValue.height)")
//                                .padding()
//                                .background(Color.black.opacity(0.1))
//                        }
                }
            }
        }
    }

    static func layout(for alignment: HorizontalAlignment) -> some View {
        FlowLayout(alignment: alignment, spacing: 16) {
            Label("text", systemImage: "clock")
                .padding(4)
                .background(Color.red)
            
            Label("Vždy druhý dlouhý text", systemImage: "clock")
                .padding(4)
                .background(Color.red)
            
            ForEach(0..<10, id: \.self) { number in
                Label("text\(number.isMultiple(of: 4) ? " delší text" : "")", systemImage: "clock")
                    .padding(4)
                    .background(Color.red)
            }
            
            Label("Vždy předpolsední", systemImage: "clock")
                .padding(4)
                .background(Color.red)
            
            Label("Vždy poslední dlouhý text", systemImage: "clock")
                .padding(4)
                .background(Color.red)
        }
    }
}
#endif
