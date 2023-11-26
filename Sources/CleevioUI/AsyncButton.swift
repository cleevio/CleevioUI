//
//  AsyncButton.swift
//  
//
//  Created by Lukáš Valenta on 23.08.2023.
//

import SwiftUI

/// A button that performs an asynchronous action when tapped while guarding that the action cannot be run again while the previous one is still running.
@available(macOS 10.15, *)
public struct AsyncButton<Label: View, Identifier: Equatable>: View {

    /// The identifier of the button.
    public var id: Identifier

    /// The asynchronous action to perform when the button is tapped.
    public var action: () async -> Void
    
    /// The label of the button.
    public var label: Label
    
    /// Internal state to track whether the action is currently executing a task.
    @Binding public var isExecuting: Identifier?

    /// Internal state to track whether the action is currently executing.
    @State private var isExecutingInternal = false

    /// Creates an asynchronous button with the given action and label.
    /// - Parameters:
    ///   - executingID: The unique identifier of the button that is used for setting isExecuting binding.
    ///   - isExecuting: A Binding that stores and sets the currently executing identifier.
    ///   - action: The asynchronous action to perform when the button is tapped.
    ///   - label: A closure returning the label of the button.
    public init(executingID: Identifier,
                isExecuting: Binding<Identifier?>,
                action: @escaping () async -> Void,
                label: () -> Label) {
        self.action = action
        self.id = executingID
        self.label = label()
        self._isExecuting = isExecuting
    }
    
    /// The body of the asynchronous button.
    public var body: some View {
        let isButtonExecuting = isExecutingInternal || isExecuting == id

        return Button(action: {
            guard isExecuting == nil else { return }

            Task { @MainActor in
                isExecuting = id
                isExecutingInternal = true

                await action()

                isExecuting = nil
                isExecutingInternal = false
            }
        }, label: { label })
        .isLoading(isButtonExecuting)
        .disabled(!isButtonExecuting && isExecuting != nil)
    }
}

/// An extension for AsyncButton with a default label of type Text.
@available(macOS 10.15, *)
extension AsyncButton where Label == Text {
    
    /// Creates an asynchronous button with the given title and action.
    /// - Parameters:
    ///   - title: The title of the button.
    ///   - executingID: The unique identifier of the button that is used for setting isExecuting binding.
    ///   - isExecuting: A Binding that stores and sets the currently executing identifier.
    ///   - action: The asynchronous action to perform when the button is tapped.
    @inlinable
    public init(_ title: some StringProtocol,
                executingID: Identifier,
                isExecuting: Binding<Identifier?>,
                action: @escaping () async -> Void) {
        self.init(executingID: executingID, isExecuting: isExecuting, action: action) { Text(title) }
    }
}

/// An extension for AsyncButton with an empty identifier.
@available(macOS 10.15, *)
extension AsyncButton where Identifier == EmptyAsyncButtonIdentifier {
    
    /// Creates an asynchronous button with the given action, label, and binding for execution state.
    /// - Parameters:
    ///   - isExecuting: A Binding that stores and sets the execution state.
    ///   - action: The asynchronous action to perform when the button is tapped.
    ///   - label: A closure returning the label of the button.
    @inlinable
    public init(isExecuting: Binding<Bool>,
                action: @escaping () async -> Void,
                label: () -> Label) {
        self.init(
            executingID: EmptyAsyncButtonIdentifier(),
            isExecuting: Binding(
                get: { isExecuting.wrappedValue ? EmptyAsyncButtonIdentifier() : nil },
                set: { isExecuting.wrappedValue = $0 != nil }),
            action: action,
            label: label
        )
    }

    /// Creates an asynchronous button with the given action and label.
    /// - Parameters:
    ///   - action: The asynchronous action to perform when the button is tapped.
    ///   - label: A closure returning the label of the button.
    @inlinable
    public init(action: @escaping () async -> Void,
                label: () -> Label) {
        self.init(
            executingID: EmptyAsyncButtonIdentifier(),
            isExecuting: .constant(nil),
            action: action,
            label: label
        )
    }
}

/// An extension for AsyncButton with an empty identifier and a default label of type Text.
@available(macOS 10.15, *)
extension AsyncButton where Identifier == EmptyAsyncButtonIdentifier, Label == Text {
    
    /// Creates an asynchronous button with the given title and action.
    /// - Parameters:
    ///   - title: The title of the button.
    ///   - action: The asynchronous action to perform when the button is tapped.
    public init(_ title: some StringProtocol,
                action: @escaping () async -> Void) {
        self.init(action: action, label: { Text(title) })
    }

    /// Creates an asynchronous button with the given title, binding for execution state, and action.
    /// - Parameters:
    ///   - title: The title of the button.
    ///   - isExecuting: A Binding that stores and sets the execution state.
    ///   - action: The asynchronous action to perform when the button is tapped.
    @inlinable
    public init(_ title: some StringProtocol,
                isExecuting: Binding<Bool>,
                action: @escaping () async -> Void) {
        self.init(isExecuting: isExecuting, action: action, label: { Text(title) })
    }
}

/// A struct representing an empty identifier.
public struct EmptyAsyncButtonIdentifier: Equatable {
    @usableFromInline
    init() { }
}

@available(iOS 15.0, macOS 11.0, *)
struct AsyncButton_Previews: PreviewProvider {
    static var solid: some ButtonStyle {
        .solid(
            labelTextColorSet: SolidButton_Previews.SolidPreviewStyle.blue.labelTextColorSet,
            labelColorSet: SolidButton_Previews.SolidPreviewStyle.blue.labelColorSet,
            outlineColorSet: SolidButton_Previews.SolidPreviewStyle.blue.outlineColorSet
        )
    }

    static var previews: some View {
        Group {
            VStack(spacing: 16) {
                AsyncButton("Test async button style") {
                    print("Doing activity")
                    try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 5)
                }
                .buttonStyle(.isLoading)
                
                AsyncButton("Test solid with async button style") {
                    print("Doing activity")
                    try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 5)
                }
                .buttonStyle(solid)
                .buttonStyle(.isLoading)
                
                AsyncButton("Test async with solid button style") {
                    try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 5)
                }
                .buttonStyle(.isLoading)
                .buttonStyle(solid)
            }

            synchronizedAsyncButtons

            differentIDAsyncButtons
        }
    }

    static var synchronizedAsyncButtons: some View {
        StatePreview(initial: false) { binding in
            VStack {
                AsyncButton("AsyncButton", isExecuting: binding) {
                    print("Doing activity")
                    try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 5)
                }
                .buttonStyle(.isLoading)
                
                AsyncButton("Bindable solid button with  async style", isExecuting: binding) {
                    print("Doing activity")
                    try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 1)
                }
                .buttonStyle(solid)
                .buttonStyle(.isLoading)

                AsyncButton("AsyncButton with solid style", isExecuting: binding) {
                    print("Doing activity")
                    try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 3)
                }
                .buttonStyle(.isLoading)
                .buttonStyle(solid)
            }
        }
        .previewDisplayName("Synchronized AsyncButtons")
    }

    static var differentIDAsyncButtons: some View {
        StatePreview(initial: Optional<Int>.none) { binding in
            VStack(spacing: 16) {
                AsyncButton("AsyncButton", executingID: 1, isExecuting: binding) {
                    try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 5)
                }
                .buttonStyle(.isLoading)
             
                AsyncButton("Bindable solid button with  async style", executingID: 3, isExecuting: binding) {
                    try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 1)
                }
                .buttonStyle(solid)
                .buttonStyle(.isLoading)

                AsyncButton("AsyncButton with solid style", executingID: 1, isExecuting: binding) {
                    try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 3)
                }
                .buttonStyle(.isLoading)
                .buttonStyle(solid)
            }
        }
        .previewDisplayName("DIfferent ID AsyncButton")
    }
}
