//
//  FlowLayoutTests.swift
//  
//
//  Created by Lukáš Valenta on 07.12.2023.
//

import XCTest
@testable import CleevioUI
import SwiftUI

@available(iOS 16.0, *)
final class FlowLayoutTests: XCTestCase {
    func testCalculatedLayoutBuilder() {
        // Given
        let subviewSizes: [CGSize] = [CGSize(width: 50, height: 30), CGSize(width: 70, height: 40)]
        let totalWidth: CGFloat = 200
        let alignment: HorizontalAlignment = .center
        let spacing: CGFloat = 8.0

        // When
        let builder = FlowLayout.CalculatedLayout.Builder(
            subviewSizes: subviewSizes,
            totalWidth: totalWidth,
            alignment: alignment,
            spacing: spacing
        )
        let calculatedLayout = builder.calculatedLayout()

        // Then
        XCTAssertEqual(calculatedLayout.frames.count, subviewSizes.count)
        XCTAssertEqual(calculatedLayout.size.width, 128) // 128 = subviewSizes width (50+70) + spacing 8

        // Check that the frames are correctly positioned
        // TODO:

        // Check that the height is equal to the maximum height among subviews
        let expectedHeight = max(subviewSizes[0].height, subviewSizes[1].height)
        XCTAssertEqual(calculatedLayout.size.height, expectedHeight)
    }

    func testCalculatedLayoutBuilder_FramePositions() {
        // Given
        let subviewSizes: [CGSize] = [CGSize(width: 50, height: 30), CGSize(width: 70, height: 40)]
        let totalWidth: CGFloat = 200

        // When
        let builder = FlowLayout.CalculatedLayout.Builder(
            subviewSizes: subviewSizes,
            totalWidth: totalWidth,
            alignment: .center,
            spacing: 8
        )
        let calculatedLayout = builder.calculatedLayout()

        // Then
        XCTAssertEqual(calculatedLayout.frames[0].origin.x, 0)
        XCTAssertEqual(calculatedLayout.frames[1].origin.x, 58) // 50 (width of the first subview) + 8 (spacing)
    }

    func testCalculatedLayoutBuilder_SingleSubview() {
        // Given
        let singleSubviewSize: [CGSize] = [CGSize(width: 100, height: 60)]
        let totalWidth: CGFloat = 150

        // When
        let builder = FlowLayout.CalculatedLayout.Builder(
            subviewSizes: singleSubviewSize,
            totalWidth: totalWidth,
            alignment: .center,
            spacing: 8
        )
        let calculatedLayout = builder.calculatedLayout()

        // Then
        XCTAssertEqual(calculatedLayout.frames.count, singleSubviewSize.count)
        XCTAssertEqual(calculatedLayout.size.width, 100) // Width of the single subview
        XCTAssertEqual(calculatedLayout.size.height, 60)
    }

    func testCalculatedLayoutBuilder_AlignmentLeading() {
        // Given
        let subviewSizes: [CGSize] = [CGSize(width: 50, height: 30), CGSize(width: 70, height: 40)]
        let totalWidth: CGFloat = 200
        let alignment: HorizontalAlignment = .leading
        let spacing: CGFloat = 8.0

        // When
        let builder = FlowLayout.CalculatedLayout.Builder(
            subviewSizes: subviewSizes,
            totalWidth: totalWidth,
            alignment: alignment,
            spacing: spacing
        )
        let calculatedLayout = builder.calculatedLayout()

        // Then
        XCTAssertEqual(calculatedLayout.frames[0].origin.x, 0)
        XCTAssertEqual(calculatedLayout.frames[1].origin.x, 58) // 50 (width of the first subview) + 8 (spacing)
    }

    func testCalculatedLayoutBuilder_AlignmentTrailing() {
        // Given
        let subviewSizes: [CGSize] = [CGSize(width: 50, height: 30), CGSize(width: 70, height: 40)]
        let totalWidth: CGFloat = 200
        let alignment: HorizontalAlignment = .trailing
        let spacing: CGFloat = 8.0

        // When
        let builder = FlowLayout.CalculatedLayout.Builder(
            subviewSizes: subviewSizes,
            totalWidth: totalWidth,
            alignment: alignment,
            spacing: spacing
        )
        let calculatedLayout = builder.calculatedLayout()

        // Then
        XCTAssertEqual(calculatedLayout.frames[0].origin.x, 0) //
        XCTAssertEqual(calculatedLayout.frames[1].origin.x, 58) // 50 (width of the first subview) + 8 (spacing)
    }

    func testCalculatedLayoutBuilder_AlignmentCenter() {
        // Given
        let subviewSizes: [CGSize] = [CGSize(width: 50, height: 30), CGSize(width: 70, height: 40)]
        let totalWidth: CGFloat = 200
        let alignment: HorizontalAlignment = .center
        let spacing: CGFloat = 8.0

        // When
        let builder = FlowLayout.CalculatedLayout.Builder(
            subviewSizes: subviewSizes,
            totalWidth: totalWidth,
            alignment: alignment,
            spacing: spacing
        )
        let calculatedLayout = builder.calculatedLayout()

        // Then
        XCTAssertEqual(calculatedLayout.frames[0].origin.x, 0)
        XCTAssertEqual(calculatedLayout.frames[1].origin.x, 58) // 50 (width of the first subview) + 8 (spacing)
    }

    func testCalculatedLayoutBuilder_AlignmentLeading_MultipleSubviews() {
        // Given
        let subviewSizes: [CGSize] = [
            CGSize(width: 50, height: 30),
            CGSize(width: 70, height: 40),
            CGSize(width: 60, height: 35),
            CGSize(width: 55, height: 45)
        ]
        let totalWidth: CGFloat = 200
        let alignment: HorizontalAlignment = .leading
        let spacing: CGFloat = 8.0

        // When
        let builder = FlowLayout.CalculatedLayout.Builder(
            subviewSizes: subviewSizes,
            totalWidth: totalWidth,
            alignment: alignment,
            spacing: spacing
        )
        let calculatedLayout = builder.calculatedLayout()

        // Then
        XCTAssertEqual(calculatedLayout.frames[0].origin.x, 0)
        XCTAssertEqual(calculatedLayout.frames[1].origin.x, 58) // 50 (width of the first subview) + 8 (spacing)
        XCTAssertEqual(calculatedLayout.frames[2].origin.x, 0) //
        XCTAssertEqual(calculatedLayout.frames[3].origin.x, 68) // 60 (width of the third subview) + 8 (spacing
    }

    func testCalculatedLayoutBuilder_AlignmentTrailing_MultipleSubviews() {
        // Given
        let subviewSizes: [CGSize] = [
            CGSize(width: 50, height: 30),
            CGSize(width: 70, height: 40),
            CGSize(width: 60, height: 35),
            CGSize(width: 55, height: 45)
        ]
        let totalWidth: CGFloat = 200
        let alignment: HorizontalAlignment = .trailing
        let spacing: CGFloat = 8.0

        // When
        let builder = FlowLayout.CalculatedLayout.Builder(
            subviewSizes: subviewSizes,
            totalWidth: totalWidth,
            alignment: alignment,
            spacing: spacing
        )
        let calculatedLayout = builder.calculatedLayout()

        // Then
        XCTAssertEqual(calculatedLayout.frames[0].origin.x, 0) // longest row
        XCTAssertEqual(calculatedLayout.frames[1].origin.x, 58) // 50 (width of the first subview) + 8 (spacing)
        XCTAssertEqual(calculatedLayout.frames[2].origin.x, 5) // Different origin due to row 3 being shorter by 5
        XCTAssertEqual(calculatedLayout.frames[3].origin.x, 73) // 5 (origin of the third subview) + 60 (width of the third subview) + 8 (spacing)
    }

    func testCalculatedLayoutBuilder_AlignmentCenter_MultipleSubviews() {
        // Given
        let subviewSizes: [CGSize] = [
            CGSize(width: 50, height: 30),
            CGSize(width: 70, height: 40),
            CGSize(width: 60, height: 35),
            CGSize(width: 55, height: 45)
        ]
        let totalWidth: CGFloat = 200
        let alignment: HorizontalAlignment = .center
        let spacing: CGFloat = 8.0

        // When
        let builder = FlowLayout.CalculatedLayout.Builder(
            subviewSizes: subviewSizes,
            totalWidth: totalWidth,
            alignment: alignment,
            spacing: spacing
        )
        let calculatedLayout = builder.calculatedLayout()

        // Then
        XCTAssertEqual(calculatedLayout.frames[0].origin.x, 0) // longest row
        XCTAssertEqual(calculatedLayout.frames[1].origin.x, 58) // 50 (width of the first subview) + 8 (spacing)
        XCTAssertEqual(calculatedLayout.frames[2].origin.x, 2.5) // Different origin due to row 3 being shorter by 5 (5/2)
        XCTAssertEqual(calculatedLayout.frames[3].origin.x, 70.5) // 2.5 (origin of the third subview) + 60 (width of the third subview) + 8 (spacing)
    }

}
