import SwiftUI

/// `SegmentedControl` is a custom SwiftUI view for creating a segmented control with various configuration options.
///
/// Example usage:
///
/// ```swift
/// SegmentedControl(
///     segments: ["Option 1", "Option 2", "Option 3"],
///     selection: $selectedSegment,
///     configuration: .init(scroll: .ifNeeded, spacing: 16),
///     button: { action, segment in
///         Button(action: action) {
///             Text(segment)
///                 .padding(8)
///         }
///     },
///     indicator: {
///         Rectangle()
///             .foregroundColor(.blue)
///             .frame(height: 2)
///     }
/// )
/// ```
@available(iOS 14.0, macOS 11.0, *)
public struct SegmentedControl<Segment: Selectable, ButtonView: View, Indicator: View>: View {

    /// Configuration options for the `SegmentedControl`.
    public struct Configuration {
        /// Determines how the segmented control should handle scrolling if there are too many segments to fit.
        public enum Scroll {
            /// Always allow scrolling.
            case always
            /// Allow scrolling only if needed.
            ///
            /// This property takes effect on iOS 16 and newer. If selected on older systems it defaults to `.always`.
            case ifNeeded
            /// Never scroll, but allow scaling down with a minimum scale factor.
            case never(minimumScaleFactor: CGFloat)
        }

        /// Determines the transition effect for the indicator when switching between segments.
        public enum IndicatorTransition {
            /// Slide the indicator from the previously selected segment to the currently selected segment with animation.
            case slide(Animation)
            /// Swap the indicator with a transition effect when switching segments.
            case swap(AnyTransition)
        }

        /// The scrolling behavior of the segmented control.
        @usableFromInline
        let scroll: Scroll
        /// The transition effect for the indicator.
        @usableFromInline
        let indicatorTransition: IndicatorTransition
        /// Spacing between individual segments.
        @usableFromInline
        let spacing: CGFloat

        /// Initializes the configuration with optional parameters.
        ///
        /// - Parameters:
        ///   - scroll: The scrolling behavior of the segmented control. Default is `.ifNeeded`.
        ///   - indicatorTransition: The transition effect for the indicator. Default is a sliding animation.
        ///   - spacing: The spacing between segments. Default is 24.
        @inlinable
        public init(
            scroll: Scroll = .ifNeeded,
            indicatorTransition: IndicatorTransition = .slide(.default),
            spacing: CGFloat = 24
        ) {
            self.scroll = scroll
            self.indicatorTransition = indicatorTransition
            self.spacing = spacing
        }
    }

    /// An array of segments that represent the options in the segmented control.
    let segments: [Segment]
    /// A binding to the currently selected segment.
    @Binding var selection: Segment
    /// The configuration settings for the segmented control.
    let configuration: Configuration
    /// A closure to create the buttons for each segment.
    @ViewBuilder var button: (@escaping () -> Void, Segment) -> ButtonView
    /// The view representing the indicator.
    let indicator: Indicator
    /// A private namespace for coordinating matched geometry effects.
    @Namespace private var namespace

    /// Creates a `SegmentedControl` with the specified parameters.
    ///
    /// - Parameters:
    ///   - segments: An array of segments representing the options.
    ///   - selection: A binding to the currently selected segment.
    ///   - configuration: The configuration settings for the segmented control.
    ///   - button: A closure to create the buttons for each segment.
    ///   - indicator: A closure to create the view representing the indicator.
    public init(
        segments: [Segment],
        selection: Binding<Segment>,
        configuration: Configuration,
        @ViewBuilder button: @escaping (@escaping () -> Void, Segment) -> ButtonView,
        @ViewBuilder indicator: @escaping () -> Indicator
    ) {
        self.segments = segments
        self._selection = selection
        self.configuration = configuration
        self.button = button
        self.indicator = indicator()
    }

    /// The body of the `SegmentedControl` view.
    public var body: some View {
        switch configuration.scroll {
        case .always:
            buttonsScrollView
        case .ifNeeded:
            if #available(iOS 16.0, macOS 13.0, *) {
                ViewThatFits(in: .horizontal) {
                    buttonsView
                        .scaledToFit()
                    buttonsScrollView
                }
            } else {
                buttonsScrollView
            }
        case let .never(minimumScaleFactor):
            buttonsView
                .scaledToFit()
                .minimumScaleFactor(minimumScaleFactor)
        }
    }

    /// A scrollable view for the segmented control buttons.
    @ViewBuilder var buttonsScrollView: some View {
        if #available(iOS 16.0, macOS 13.0, *) {
            ScrollView(.horizontal) {
                buttonsView
            }
            .scrollIndicators(.hidden)
        } else {
            ScrollView(showsIndicators: false) {
                buttonsView
            }
        }
    }

    /// The view that displays the segmented control buttons.
    var buttonsView: some View {
        HStack(spacing: configuration.spacing) {
            ForEach(segments.indices, id: \.self, content: { index in
                let segment = segments[index]
                button({ selection = segment }, segment)
                    .matchedGeometryEffect(
                        id: segment.id,
                        in: namespace
                    )
                    .accessibilityIdentifier(.button("segment.\(index)"))
                    .background(
                        swapIndicator(for: segment)
                    )
            })
        }
        .background(slideIndicator)
        .animation(.default, value: selection)
    }

    @ViewBuilder 
    func swapIndicator(for segment: Segment) -> some View {
        if case let .swap(anyTransition) = configuration.indicatorTransition, segment.id == selection.id {
            SwapIndicatorContainer(
                transition: anyTransition,
                indicator: indicator
            )
        }
    }

    @ViewBuilder
    var slideIndicator: some View {
        if case let .slide(animation) = configuration.indicatorTransition {
            SlideIndicatorContainer(
                selection: selection,
                namespace: namespace,
                animation: animation,
                indicator: indicator
            )
        }
    }

    /// `SwapIndicatorContainer` is a view used for rendering the indicator within a `SegmentedControl`. It dynamically displays the indicator based on the selected segment and transition configuration.
    struct SwapIndicatorContainer: View {
        /// The configuration specifying how the indicator should transition between segments.
        let transition: AnyTransition
        /// The view representing the indicator.
        let indicator: Indicator

        /// The body of the `SwapIndicatorContainer` view.
        var body: some View {
            indicator
                .transition(transition)
        }
    }

    /// `SlideIndicatorContainer` is a view used for rendering the indicator within a `SegmentedControl`. It provides a sliding animation effect for the indicator as it transitions between segments.
    struct SlideIndicatorContainer: View {
        /// The segment that is currently selected.
        let selection: Segment
        /// The namespace used for coordinating matched geometry effects.
        let namespace: Namespace.ID
        /// The configuration specifying how the indicator should animate between segments.
        let animation: Animation
        /// The view representing the indicator.
        let indicator: Indicator

        /// The body of the `SlideIndicatorContainer` view.
        var body: some View {
            indicator
                .matchedGeometryEffect(
                    id: selection.id,
                    in: namespace,
                    isSource: false
                )
                .animation(animation, value: selection)
        }
    }
}

/// A view for displaying a rounded line indicator.
@available(macOS 10.15, *)
public struct RoundedLineIndicator: View {
    /// Configuration settings for the RoundedLineIndicator.
    public struct Configuration {
        /// The color of the indicator.
        @usableFromInline
        let fill: Color
        /// The corner radius of the indicator.
        @usableFromInline
        let cornerRadius: CGFloat
        /// The height of the indicator.
        @usableFromInline
        let height: CGFloat
        /// The height of the indicator. If nil is provided, the indicator takes the width of the segment
        @usableFromInline
        let width: CGFloat?

        /// Initializes the configuration with optional parameters.
        ///
        /// - Parameters:
        ///   - fill: The color of the indicator. Default is the system's default color.
        ///   - cornerRadius: The corner radius of the indicator. Default is 4.
        ///   - height: The height of the indicator. Default is 4.
        ///   - width: The height of the indicator. If nil is provided, the indicator takes the width of the segment. Default is nil.
        @inlinable
        public init(
            fill: Color,
            cornerRadius: CGFloat = 4,
            height: CGFloat = 4,
            width: CGFloat? = nil
        ) {
            self.cornerRadius = cornerRadius
            self.fill = fill
            self.height = height
            self.width = width
        }
    }

    @usableFromInline
    let configuration: Configuration

    /// Initializes a RoundedLineIndicator with the provided configuration.
    ///
    /// - Parameter configuration: The configuration settings for the indicator.
    @inlinable
    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    /// The body of the RoundedLineIndicator view.
    public var body: some View {
        VStack {
            Spacer()
            RoundedRectangle(cornerRadius: configuration.cornerRadius, style: .continuous)
                .fill(configuration.fill)
                .frame(width: configuration.width, height: configuration.height, alignment: .center)
                .frame(maxWidth: .infinity)
        }
    }
}


/// `PaddedTitleButton` is a view used internally by CleevioUI and should not be instantiated directly.
/// It is specifically designed for the default implementation of `SegmentedControl`.
///
/// If you need to customize a button for `SegmentedControl`, use other available initializers.
@available(macOS 10.15, *)
public struct PaddedTitleButton: View {
    /// The title displayed on the button.
    let title: String

    /// The padding applied to the button.
    let padding: EdgeInsets

    /// The action to be executed when the button is tapped.
    let action: () -> Void

    @usableFromInline
    init(title: String, padding: EdgeInsets, action: @escaping () -> Void) {
        self.title = title
        self.padding = padding
        self.action = action
    }

    /// The body of the `PaddedTitleButton` view, which renders a button with the provided title and padding.
    public var body: some View {
        Button(title, action: action)
            .padding(padding)
    }
}


/// An extension of the `SegmentedControl` to provide a convenient initializer with default `ButtonView` and `Indicator`.
@available(iOS 14.0, macOS 11.0, *)
extension SegmentedControl where ButtonView == PaddedTitleButton, Indicator == RoundedLineIndicator {
    /// Creates a `SegmentedControl` with custom configurations for the button titles and indicator.
    ///
    /// - Parameters:
    ///   - segments: An array of segments representing the options.
    ///   - selection: A binding to the currently selected segment.
    ///   - titlePadding: The padding around the button titles. Default is 8 points at the top and bottom.
    ///   - configuration: The configuration settings for the segmented control.
    ///   - indicatorConfiguration: The configuration settings for the indicator.
    ///
    /// - Note: It is expected that the user changes foreground color, font, or any other selection-dependent property themselves based on the value of `selection`.
    @inlinable
    public init(
        segments: [Segment],
        selection: Binding<Segment>,
        titlePadding: EdgeInsets = .init(top: 8, leading: 0, bottom: 8, trailing: 0),
        configuration: Configuration = .init(),
        indicatorConfiguration: RoundedLineIndicator.Configuration
    ) {
        self.init(
            segments: segments,
            selection: selection,
            configuration: configuration,
            button: { action, segment in PaddedTitleButton(title: segment.title, padding: titlePadding, action: action) },
            indicator: { RoundedLineIndicator(configuration: indicatorConfiguration) }
        )
    }
}
