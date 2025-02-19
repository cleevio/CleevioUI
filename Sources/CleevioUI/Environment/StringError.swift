import SwiftUI

public struct StringErrorKey: EnvironmentKey {
    public static let defaultValue: String? = nil
}

@available(macOS 10.15, *)
public extension EnvironmentValues {
    @inlinable
    var stringError: String? {
        get { self[StringErrorKey.self] }
        set { self[StringErrorKey.self] = newValue }
    }
}

@available(macOS 10.15, *)
public extension View {
    @inlinable
    func error(_ value: String?) -> some View {
        environment(\.stringError, value)
    }
}
