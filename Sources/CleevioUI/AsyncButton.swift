//
//  AsyncButton.swift
//  
//
//  Created by Lukáš Valenta on 23.08.2023.
//

import SwiftUI

public struct AsyncButton<Label: View>: View {
    public var action: () async -> Void
    public var label: Label
    @State private var isExecuting = false

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

extension AsyncButton where Label == Text {
    @inlinable
    public init(_ title: some StringProtocol, action: @escaping () async -> Void) {
        self.init(action: action) { Text(title) }
    }
}

@available(iOS 14.0, *)
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
