import Foundation

/// `Selectable` is a protocol that represents an item that can be selected.
@available(macOS 10.15, *)
public protocol Selectable: Identifiable, Hashable, CustomStringConvertible {

    /// A human-readable title for the selectable item.
    var title: String { get }
}

// Default implementations for Selectable protocol
@available(macOS 10.15, *)
public extension Selectable {

    /// The default implementation for the `id` property required by the `Identifiable` protocol.
    ///
    /// By default, it returns `self`, but conforming types can provide their own implementation.
    var id: Self { self }

    /// The default implementation for the `description` property required by the `CustomStringConvertible` protocol.
    ///
    /// By default, it returns the `title` property, providing a human-readable description of the item.
    var description: String { title }
}


