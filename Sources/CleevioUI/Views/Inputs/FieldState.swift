import SwiftUI

public struct InputFieldState: Equatable, Hashable, Codable {
    public var isFocused: Bool
    public var isEnabled: Bool
    public var isError: Bool
}

@available(macOS 10.15, *)
public struct InputFieldStateColorSet {
    public var unfocused: Color
    public var focused: Color
    public var error: Color
    public var disabled: Color

    public var resolve: (InputFieldState) -> Color

    public init(unfocused: Color, focused: Color, error: Color, disabled: Color, resolve: @escaping (InputFieldState) -> Color) {
        self.unfocused = unfocused
        self.focused = focused
        self.error = error
        self.disabled = disabled
        self.resolve = resolve
    }

    public init(unfocused: Color, focused: Color, error: Color, disabled: Color) {
        self.unfocused = unfocused
        self.focused = focused
        self.error = error
        self.disabled = disabled
        self.resolve = { state in
            if state.isError { return error }
            if state.isFocused { return focused }
            if state.isEnabled { return unfocused }
            return disabled
        }
    }
}

@dynamicMemberLookup
public struct TextFieldState {
    public var isEmpty: Bool
    public var inputFieldState: InputFieldState

    public init(isEmpty: Bool, inputFieldState: InputFieldState) {
        self.isEmpty = isEmpty
        self.inputFieldState = inputFieldState
    }

    subscript<T>(dynamicMember keyPath: KeyPath<InputFieldState, T>) -> T {
        inputFieldState[keyPath: keyPath]
    }
}

@available(macOS 10.15, *)
public struct TextFieldStateColorSet {
    var colorSet: InputFieldStateColorSet

    public var resolve: (TextFieldState) -> Color

    public init(colorSet: InputFieldStateColorSet, resolve: @escaping (TextFieldState) -> Color) {
        self.colorSet = colorSet
        self.resolve = resolve
    }

    public init(colorSet: InputFieldStateColorSet) {
        self.init(
            colorSet: colorSet,
            resolve: { colorSet.resolve($0.inputFieldState) }
        )
    }
}
