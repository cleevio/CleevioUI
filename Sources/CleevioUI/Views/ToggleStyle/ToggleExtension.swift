import SwiftUI

@available(macOS 10.15, *)
extension Toggle where Label == EmptyView {

    /// Initializes a Toggle with a custom binding to a Boolean value and an empty label.
    ///
    /// Use this convenience initializer to create a Toggle when you only need to specify the binding to a Boolean value. The label is automatically set to an empty view.
    ///
    /// - Parameters:
    ///   - isOn: A binding to a Boolean value that determines the state of the Toggle.
    ///
    /// Example:
    /// ```swift
    /// @State private var isToggled = false
    ///
    /// var body: some View {
    ///     Toggle(isOn: $isToggled)
    /// }
    /// ```
    ///
    /// - Returns: A Toggle with an empty label and a binding to a Boolean value.
    public init(isOn: Binding<Bool>) {
        self.init(isOn: isOn, label: EmptyView.init)
    }
}
