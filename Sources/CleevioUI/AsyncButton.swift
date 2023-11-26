//
//  AsyncButton.swift
//  
//
//  Created by Lukáš Valenta on 23.08.2023.
//

import SwiftUI

/// An option set that defines behaviors for `AsyncButton`.
public struct AsyncButtonOptions: OptionSet {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    /// An option that allows the button to initiate multiple executions concurrently.
    public static let allowsConcurrentExecutions = Self(rawValue: 1 << 0)

    /// An option that causes the button to abort any running execution when a new execution is initiated.
    public static let cancelsRunningExecution = Self(rawValue: 1 << 1)
}

/// A button that initiates an asynchronous action when tapped.
///
/// This button is designed to handle concurrent or repeated taps by using the behaviors defined in `AsyncButtonOptions`.
@available(macOS 10.15, *)
public struct AsyncButton<Label: View, Identifier: Equatable>: View {

    /// The unique identifier for the button.
    public var id: Identifier

    /// The asynchronous action to perform when the button is tapped.
    public var action: () async -> Void
    
    /// The visual label for the button.
    public var label: Label
    
    /// A binding that tracks whether the button's action is currently executing.
    @Binding public var isExecuting: Identifier?

    /// The options that define the button's behavior when it's tapped.
    public var options: AsyncButtonOptions

    /// A private state that tracks whether the button's action is currently executing.
    @State private var isExecutingInternal = false

    /// The last running task, stored for potential cancellation.
    @State private var savedTask: Task<Void, Never>?

    /// Creates a new asynchronous button with the given parameters.
    ///
    /// - Parameters:
    ///   - executingID: The unique identifier for the button.
    ///   - isExecuting: A binding that sets and stores the currently executing identifier.
    ///   - options: The options that define the button's behavior when it's tapped.
    ///   - action: The asynchronous action to perform when the button is tapped.
    ///   - label: A closure that returns the button's visual label.
    public init(executingID: Identifier,
                isExecuting: Binding<Identifier?>,
                options: AsyncButtonOptions = [],
                action: @escaping () async -> Void,
                label: () -> Label) {
        self.action = action
        self.id = executingID
        self.options = options
        self.label = label()
        self._isExecuting = isExecuting
    }
    
    /// The body of the asynchronous button.
    public var body: some View {
        let isButtonExecuting = isExecutingInternal || isExecuting == id

        return Button(action: {
            guard !isButtonExecuting || options.contains(.allowsConcurrentExecutions) else { return }

            if options.contains(.cancelsRunningExecution) {
                savedTask?.cancel()
            }

            savedTask = Task { @MainActor in
                if isExecuting != id {
                    isExecuting = id
                }

                if !isExecutingInternal {
                    isExecutingInternal = true
                }

                await action()

                if !Task.isCancelled {
                    isExecuting = nil
                    isExecutingInternal = false
                }
            }
        }, label: { label })
        .isLoading(isButtonExecuting)
        .disabled(!options.contains(.allowsConcurrentExecutions) && ( isButtonExecuting || isExecuting != nil))
    }
}

/// An extension for AsyncButton with a default label of type Text.
@available(macOS 10.15, *)
extension AsyncButton where Label == Text {
    
    /// Creates an asynchronous button with the given title and action.
    ///
    /// - Parameters:
    ///   - title: The title of the button.
    ///   - executingID: The unique identifier of the button that is used for setting isExecuting binding.
    ///   - isExecuting: A Binding that stores and sets the currently executing identifier.
    ///   - options: The options that define the button's behavior when it's tapped.
    ///   - action: The asynchronous action to perform when the button is tapped.
    @inlinable
    public init(_ title: some StringProtocol,
                executingID: Identifier,
                isExecuting: Binding<Identifier?>,
                options: AsyncButtonOptions = [],
                action: @escaping () async -> Void) {
        self.init(executingID: executingID, isExecuting: isExecuting, options: options, action: action) { Text(title) }
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
                options: AsyncButtonOptions = [],
                action: @escaping () async -> Void,
                label: () -> Label) {
        self.init(
            executingID: EmptyAsyncButtonIdentifier(),
            isExecuting: Binding(
                get: { isExecuting.wrappedValue ? EmptyAsyncButtonIdentifier() : nil },
                set: { isExecuting.wrappedValue = $0 != nil })
            , options: options,
            action: action,
            label: label
        )
    }

    /// Creates an asynchronous button with the given action and label.
    /// - Parameters:
    ///   - options: The options that define the button's behavior when it's tapped.
    ///   - action: The asynchronous action to perform when the button is tapped.
    ///   - label: A closure returning the label of the button.
    @inlinable
    public init(options: AsyncButtonOptions = [],
                action: @escaping () async -> Void,
                label: () -> Label) {
        self.init(
            executingID: EmptyAsyncButtonIdentifier(),
            isExecuting: .constant(nil),
            options: options,
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
    ///   - options: The options that define the button's behavior when it's tapped.
    ///   - action: The asynchronous action to perform when the button is tapped.
    @inlinable
    public init(_ title: some StringProtocol,
                options: AsyncButtonOptions = [],
                action: @escaping () async -> Void) {
        self.init(options: options, action: action, label: { Text(title) })
    }

    /// Creates an asynchronous button with the given title, binding for execution state, and action.
    /// - Parameters:
    ///   - title: The title of the button.
    ///   - isExecuting: A Binding that stores and sets the execution state.
    ///   - options: The options that define the button's behavior when it's tapped.
    ///   - action: The asynchronous action to perform when the button is tapped.
    @inlinable
    public init(_ title: some StringProtocol,
                isExecuting: Binding<Bool>,
                options: AsyncButtonOptions = [],
                action: @escaping () async -> Void) {
        self.init(isExecuting: isExecuting, options: options, action: action, label: { Text(title) })
    }
}

/// A struct representing an empty identifier.
public struct EmptyAsyncButtonIdentifier: Equatable {
    @usableFromInline
    init() { }
}

@available(iOS 15.0, macOS 12.0, *)
struct AsyncButton_Previews: PreviewProvider {
    static var solid: some ButtonStyle {
        .solid(
            labelTextColorSet: SolidButton_Previews.SolidPreviewStyle.blue.labelTextColorSet,
            labelColorSet: SolidButton_Previews.SolidPreviewStyle.blue.labelColorSet,
            outlineColorSet: SolidButton_Previews.SolidPreviewStyle.blue.outlineColorSet
        )
    }

    static func buttonAction(timeInSeconds: UInt64) async {
        print("Doing activity")
        try? await Task.sleep(nanoseconds: NSEC_PER_SEC * timeInSeconds)

        if Task.isCancelled {
            print("Task is canceled")
        } else {
            print("Finished")
        }
    }

    static var previews: some View {
        Group {
            VStack(spacing: 16) {
                AsyncButton("Test async button style", options: [.allowsConcurrentExecutions, .cancelsRunningExecution]) {
                    await buttonAction(timeInSeconds: 5)
                }
                .buttonStyle(.isLoading)
                
                AsyncButton("Test solid with async button style") {
                    await buttonAction(timeInSeconds: 5)
                }
                .buttonStyle(solid)
                .buttonStyle(.isLoading)
                
                AsyncButton("Test async with solid button style") {
                    await buttonAction(timeInSeconds: 5)
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
                    await buttonAction(timeInSeconds: 5)
                }
                .buttonStyle(.isLoading)
                
                AsyncButton("Bindable solid button with  async style", isExecuting: binding) {
                    await buttonAction(timeInSeconds: 1)
                }
                .buttonStyle(solid)
                .buttonStyle(.isLoading)

                AsyncButton("AsyncButton with solid style", isExecuting: binding) {
                    await buttonAction(timeInSeconds: 3)
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
                    await buttonAction(timeInSeconds: 5)
                }
                .buttonStyle(.isLoading)
             
                AsyncButton("Bindable solid button with  async style", executingID: 3, isExecuting: binding) {
                    await buttonAction(timeInSeconds: 1)
                }
                .buttonStyle(solid)
                .buttonStyle(.isLoading)

                AsyncButton("AsyncButton with solid style", executingID: 1, isExecuting: binding) {
                    await buttonAction(timeInSeconds: 3)
                }
                .buttonStyle(.isLoading)
                .buttonStyle(solid)
            }
        }
        .previewDisplayName("DIfferent ID AsyncButton")
    }
}
