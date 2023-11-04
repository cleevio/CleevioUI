//
//  AsyncButton.swift
//  
//
//  Created by Lukáš Valenta on 23.08.2023.
//

import SwiftUI

/// A button that performs an asynchronous action when tapped that guards that the action is run maximally once at the same time.
@available(macOS 10.15, *)
public struct AsyncButton<Label: View>: View {
    /// The asynchronous action to perform when the button is tapped.
    public var action: () async -> Void
    
    /// The label of the button.
    public var label: Label
    
    /// Internal state to track whether the action is currently executing a task.
    @State private var isExecuting = false

    /// Creates an asynchronous button with the given action and label.
    /// - Parameters:
    ///   - action: The asynchronous action to perform when the button is tapped.
    ///   - label: A closure returning the label of the button.
    @inlinable
    public init(action: @escaping () async -> Void,
                label: () -> Label) {
        self.action = action
        self.label = label()
    }
    
    public var body: some View {
        Button(action: {
            guard !isExecuting else { return }

            Task { @MainActor in
                isExecuting = true

                await action()

                isExecuting = false
            }
        }, label: { label })
        .isLoading(isExecuting)
    }
}

@available(macOS 10.15, *)
extension AsyncButton where Label == Text {
    /// Creates an asynchronous button with the given title and action.
    /// - Parameters:
    ///   - title: The title of the button.
    ///   - action: The asynchronous action to perform when the button is tapped.
    @inlinable
    public init(_ title: some StringProtocol, action: @escaping () async -> Void) {
        self.init(action: action) { Text(title) }
    }
}

@available(iOS 14.0, macOS 11.0, *)
struct AsyncButton_Previews: PreviewProvider {
    static var previews: some View {
        AsyncButton(action: {
            try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 3)
        }, label: {
            Text("Async Button")
        })
        .buttonStyle(.solid(
            labelTextColorSet: SolidButton_Previews.SolidPreviewStyle.blue.labelTextColorSet,
            labelColorSet: SolidButton_Previews.SolidPreviewStyle.blue.labelColorSet,
            outlineColorSet: SolidButton_Previews.SolidPreviewStyle.blue.outlineColorSet
        ))
    }
}
