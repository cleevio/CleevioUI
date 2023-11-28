//
//  AsyncButtonTests.swift
//  
//
//  Created by Lukáš Valenta on 28.11.2023.
//

@testable import CleevioUI
import XCTest
import SwiftUI

final class AsyncButtonTests: XCTestCase {
    func testDefaultOptions() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: false, options: [])

        XCTAssertTrue(state.isNewExecutingAllowed, "It should allow new execution when not executing.")
        XCTAssertFalse(state.shouldCancelPreviousTask, "Previous task should not be canceled")
        XCTAssertFalse(state.isButtonLoading, "Button should not be loading when isExecutingInternal is false")
    }

    func testDefaultOptionsWhenExecuting() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: true, options: [])

        XCTAssertFalse(state.isNewExecutingAllowed, "It should not allow new execution when executing.")
        XCTAssertFalse(state.shouldCancelPreviousTask, "Previous task should not be canceled")
        XCTAssertTrue(state.isButtonDisabled, "Button should not be disabled with default options set when executing")
        XCTAssertTrue(state.isButtonLoading, "Button should be in loading state when isExecutingInternal is true.")
    }

    func testDefaultOptionsWhenSameIdentifierIsExecuting() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: false, isExecuting: 0, options: [])

        XCTAssertFalse(state.isNewExecutingAllowed, "It should not allow new execution when executing.")
        XCTAssertFalse(state.shouldCancelPreviousTask, "Previous task should not be canceled")
        XCTAssertTrue(state.isButtonDisabled, "Button should not be disabled with default options set and same identifier executing.")
        XCTAssertTrue(state.isButtonLoading, "Button should be in loading state when same identifier is executing.")
    }

    func testDefaultOptionsWhenExecutingWithIdentifier() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: true, isExecuting: 0, options: [])

        XCTAssertFalse(state.isNewExecutingAllowed, "It should not allow new execution when executing.")
        XCTAssertFalse(state.shouldCancelPreviousTask, "Previous task should not be canceled")
        XCTAssertTrue(state.isButtonDisabled, "Button should not be disabled with default options set and executing with identifier.")
        XCTAssertTrue(state.isButtonLoading, "Button should be in loading state when executing with same identifier.")
    }

    func testDefaultOptionsWhenDifferentIdentifierIsExecuting() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: false, isExecuting: 1, options: [])

        XCTAssertFalse(state.isNewExecutingAllowed, "It should not allow new execution when executing.")
        XCTAssertFalse(state.shouldCancelPreviousTask, "Previous task should not be canceled")
        XCTAssertTrue(state.isButtonDisabled, "Button should be disabled with default options set and isExecutingInternal is true.")
        XCTAssertFalse(state.isButtonLoading, "Button should not be in a loading state when different identifier executes.")
    }

    func testAllowsConcurrentExecutionsOption() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: true, options: .allowsConcurrentExecutions)

        XCTAssertTrue(state.isNewExecutingAllowed, "It should allow new execution when .allowsConcurrentExecutions option is set.")
        XCTAssertFalse(state.shouldCancelPreviousTask, "Previous task should not be canceled")
        XCTAssertFalse(state.isButtonDisabled, "Button should be not disabled when .allowsConcurrentExecutions option is set")
        XCTAssertTrue(state.isButtonLoading, "Button should be in loading state when isExecutingInternal is true.")
    }

    func testCancelsRunningExecutionOption() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: false, options: .cancelsRunningExecution)

        XCTAssertTrue(state.isNewExecutingAllowed, "It should not allow new execution when only .cancelsRunningExecution option is set.")
        XCTAssertTrue(state.shouldCancelPreviousTask, "Previous task should be canceled")
        XCTAssertFalse(state.isButtonLoading, "Button should not be loading when isExecutingInternal is false")
        XCTAssertFalse(state.isButtonDisabled, "Button should not be disabled when isExecutingInternal is false ")
    }

    func testCancelsRunningExecutionOptionWhenExecuting() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: true, options: .cancelsRunningExecution)

        XCTAssertFalse(state.isNewExecutingAllowed, "It should not allow new execution when only .cancelsRunningExecution option is set.")
        XCTAssertTrue(state.shouldCancelPreviousTask, "Previous task should be canceled")
        XCTAssertTrue(state.isButtonLoading, "Button should be in loading state when isExecutingInternal is true.")
        XCTAssertTrue(state.isButtonDisabled, "Button should be disabled when only .cancelsRunningExecution option is set")
    }

    func testCancelsRunningExecutionWithConcurrentExecutionsOptions() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: false, options: [.cancelsRunningExecution, .allowsConcurrentExecutions])

        XCTAssertTrue(state.isNewExecutingAllowed, "It should not allow new execution when only .cancelsRunningExecution option is set.")
        XCTAssertTrue(state.shouldCancelPreviousTask, "Previous task should be canceled")
        XCTAssertFalse(state.isButtonLoading, "Button should not be loading when isExecutingInternal is false")
        XCTAssertFalse(state.isButtonDisabled, "Button should not be disabled when .allowsConcurrentExecutions option is set")
    }

    func testCancelsRunningExecutionWithConcurrentExecutionsOptionsWhenExecuting() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: true, options: [.cancelsRunningExecution, .allowsConcurrentExecutions])

        XCTAssertTrue(state.isNewExecutingAllowed, "It should allow isNewExecutingAllowed when .allowsConcurrentExecutions option is set")
        XCTAssertTrue(state.shouldCancelPreviousTask, "Previous task should be canceled")
        XCTAssertTrue(state.isButtonLoading, "Button should be in loading state when isExecutingInternal is true.")
        XCTAssertFalse(state.isButtonDisabled, "Button should be not disabled when .allowsConcurrentExecutions option is set")
    }
}
