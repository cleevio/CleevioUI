import SwiftUI

public struct StringErrorKey: EnvironmentKey {
    public static var defaultValue: String?
}

public extension EnvironmentValues {
    var stringError: String? {
        get { self[StringErrorKey.self] }
        set { self[StringErrorKey.self] = newValue }
    }
}

public extension View {
    func error(_ value: String?) -> some View {
        environment(\.stringError, value)
    }
}
