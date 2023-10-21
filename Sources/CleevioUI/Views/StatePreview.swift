import SwiftUI

/// A view that previews a stateful UI component.
public struct StatePreview<Value, Content: View>: View {
    @State var value: Value
    var content: (Binding<Value>) -> Content

    /// Initializes a StatePreview view with an initial value and content.
    ///
    /// - Parameters:
    ///   - initial: The initial value of the state. Default is `false`.
    ///   - content: A closure that constructs the content based on a binding to the state.
    public init(initial: Value = false, content: @escaping (Binding<Value>) -> Content) {
        self._value = State(initialValue: initial)
        self.content = content
    }

    public var body: some View {
        content($value)
    }
}