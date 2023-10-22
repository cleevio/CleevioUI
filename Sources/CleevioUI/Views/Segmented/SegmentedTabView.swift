import SwiftUI

/// `SegmentedTabView` is a custom SwiftUI view for creating a segmented tab view with various configuration options.
///
/// Example usage:
///
/// ```swift
/// SegmentedTabView(
///     segments: [
///         Segment(id: 1, title: "Tab 1"),
///         Segment(id: 2, title: "Tab 2"),
///         Segment(id: 3, title: "Tab 3"),
///     ],
///     selection: $selectedSegment,
///     configuration: .init(
///         animation: .easeInOut,
///         isSwipeEnabled: true,
///         contentPadding: .init(top: 8, leading: 16, bottom: 8, trailing: 16)
///     ),
///     control: {
///         SegmentedControl(
///             segments: segments,
///             selection: $selectedSegment,
///             configuration: .init(),
///             button: { action, segment in
///                 Text(segment.title)
///                     .padding(8)
///             },
///             indicator: {
///                 Rectangle()
///                     .foregroundColor(.blue)
///                     .frame(height: 2)
///             }
///         )
///     },
///     content: { segment in
///         Text("Content for \(segment.title)")
///             .font(.title)
///             .padding()
///     }
/// )
/// ```
@available(iOS 14.0, *)
public struct SegmentedTabView<Segment: Selectable, Content: View, Control: View>: View {

    /// Configuration options for the `SegmentedTabView`.
    public struct Configuration {
        /// The animation applied when switching between segments.
        let animation: Animation
        /// Determines whether swipe gestures are enabled to navigate between segments.
        let isSwipeEnabled: Bool

        /// Initializes the configuration with optional parameters.
        ///
        /// - Parameters:
        ///   - animation: The animation applied when switching between segments. Default is `.default`.
        ///   - isSwipeEnabled: A boolean value indicating whether swipe gestures are enabled. Default is `true`.
        ///   - contentPadding: The padding applied to the content view within the tab view. Default is no padding.
        public init(
            animation: Animation = .default,
            isSwipeEnabled: Bool = true
        ) {
            self.animation = animation
            self.isSwipeEnabled = isSwipeEnabled
        }
    }

    /// An array of segments that represent the tab view's options.
    let segments: [Segment]
    /// A binding to the currently selected segment.
    @Binding var selection: Segment
    /// The configuration settings for the segmented tab view.
    let configuration: Configuration
    /// The view that acts as the tab control.
    let control: Control
    /// Content of the SegmentedTabView
    let content: Content

    /// Creates a `SegmentedTabView` with the specified parameters.
    ///
    /// - Parameters:
    ///   - segments: An array of segments representing the tab view's options.
    ///   - selection: A binding to the currently selected segment.
    ///   - configuration: The configuration settings for the segmented tab view.
    ///   - control: A closure to create the tab control.
    ///   - content: A closure to provide the content for each segment.
    public init(
        segments: [Segment],
        selection: Binding<Segment>,
        configuration: Configuration,
        @ViewBuilder control: @escaping () -> Control,
        @ViewBuilder content: () -> Content
    ) {
        self.segments = segments
        self._selection = selection
        self.configuration = configuration
        self.control = control()
        self.content = content()
    }

    /// The body of the `SegmentedTabView` view.
    public var body: some View {
        VStack(spacing: 0) {
            control
            Group {
                if configuration.isSwipeEnabled {
                    TabView(selection: $selection) {
                        content
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                } else {
                    content
                }
            }
        }
        .animation(configuration.animation, value: selection)
    }
}

