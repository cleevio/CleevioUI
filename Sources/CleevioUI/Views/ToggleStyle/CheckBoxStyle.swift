import SwiftUI

/// A custom toggle style that renders a checkbox.
public struct CheckBoxStyle<CheckBox: View>: ToggleStyle {

    /// Configuration settings for the checkbox.
    public struct Configuration {

        /// Specifies the layout of the checkbox.
        public enum Layout {
            case horizontal(alignment: VerticalAlignment = .center)
            case vertical(alignment: HorizontalAlignment = .center)
        }

        /// Spacing between the checkbox and label.
        let spacing: CGFloat
        /// Size of the checkbox.
        let size: CGSize
        /// Layout style for the checkbox.
        let layout: Layout
        /// Animation for the checkbox state change.
        let animation: Animation?

        /// Initializes a configuration object with optional parameters.
        ///
        /// - Parameters:
        ///   - spacing: The spacing between the checkbox and label. Default is 16.
        ///   - size: The size of the checkbox. Default is CGSize(width: 24, height: 24).
        ///   - layout: The layout style for the checkbox. Default is horizontal with center alignment.
        ///   - animation: The animation for checkbox state changes. Default is .default.
        public init(
            spacing: CGFloat = 16,
            size: CGSize = .init(width: 24, height: 24),
            layout: Layout = .horizontal(),
            animation: Animation? = .default
        ) {
            self.spacing = spacing
            self.size = size
            self.layout = layout
            self.animation = animation
        }

        /// Provides an abstract layout for conditional layout handling.
        ///
        /// - Returns: An abstract layout for the checkbox.
        @available(iOS 16.0, *)
        var anyLayout: AnyLayout {
            switch layout {
            case let .horizontal(alignment):
                return AnyLayout(HStackLayout(alignment: alignment, spacing: spacing))
            case let .vertical(alignment):
                return AnyLayout(VStackLayout(alignment: alignment, spacing: spacing))
            }
        }
    }

    /// The configuration settings for the checkbox.
    let viewConfiguration: Configuration
    /// A view builder closure that constructs the checkbox.
    @ViewBuilder var view: (Bool) -> CheckBox

    /// Initializes a CheckBoxStyle with the provided configuration and view builder.
    ///
    /// - Parameters:
    ///   - viewConfiguration: The configuration settings for the checkbox.
    ///   - view: A closure that constructs the checkbox.
    public init(viewConfiguration: Configuration, @ViewBuilder view: @escaping (Bool) -> CheckBox) {
        self.view = view
        self.viewConfiguration = viewConfiguration
    }

    /// Creates the body of the checkbox.
    public func makeBody(configuration: ToggleStyle.Configuration) -> some View {
        if #available(iOS 16.0, *) {
            viewConfiguration.anyLayout {
                InnerView(checkBox: view(configuration.isOn), viewConfiguration: viewConfiguration, configuration: configuration)
            }
        } else if case let .horizontal(alignment) = viewConfiguration.layout {
            HStack(alignment: alignment, spacing: viewConfiguration.spacing) {
                InnerView(checkBox: view(configuration.isOn), viewConfiguration: viewConfiguration, configuration: configuration)
            }
        } else if case let .vertical(alignment) = viewConfiguration.layout {
            VStack(alignment: alignment, spacing: viewConfiguration.spacing) {
                InnerView(checkBox: view(configuration.isOn), viewConfiguration: viewConfiguration, configuration: configuration)
            }
        }
    }

    /// Inner view that combines the checkbox with label and interaction.
    private struct InnerView: View {
        let checkBox: CheckBox
        let viewConfiguration: Configuration
        let configuration: ToggleStyle.Configuration

        var body: some View {
            checkBox
                .frame(size: viewConfiguration.size)
                .contentShape(Rectangle())
                .onTapGesture { configuration.$isOn.wrappedValue.toggle() }
                .animation(viewConfiguration.animation, value: configuration.isOn)

            configuration.label
        }
    }
}

// Extension for CheckBoxStyle where the checkbox is RoundedStrokeIconCheckBox.
extension CheckBoxStyle where CheckBox == RoundedStrokeIconCheckBox {
    /// Initializes a CheckBoxStyle for RoundedStrokeIconCheckBox-based checkboxes.
    ///
    /// - Parameters:
    ///   - on: Image to display for the "on" state.
    ///   - iconColor: Color for the checkbox icon.
    ///   - borderColorSet: Color set for the checkbox border.
    ///   - backgroundColorSet: Color set for the checkbox background.
    ///   - cornerRadius: The corner radius of the checkbox.
    ///   - borderWidth: The border width of the checkbox.
    ///   - configuration: The configuration settings for the checkbox.
    init(
        on: Image = Image(systemName: "checkmark"),
        iconColor: Color = .clear,
        borderColorSet: CheckBoxStateColorSet = .init(.white),
        backgroundColorSet: CheckBoxStateColorSet = .init(.red),
        cornerRadius: CGFloat = 4,
        borderWidth: CGFloat = 1,
        configuration: Configuration = .init()
    ) {
        self.init(viewConfiguration: configuration) { isOn in
            RoundedStrokeIconCheckBox(
                icon: isOn ? on : nil,
                iconColor: iconColor,
                size: configuration.size,
                backgroundColor: backgroundColorSet.resolve(isOn),
                stroke: RoundedStroke(
                    color: borderColorSet.resolve(isOn),
                    cornerRadius: cornerRadius,
                    lineWidth: borderWidth
                )
            )
        }
    }
}

// Extension for CheckBoxStyle where the checkbox is an Image.
extension CheckBoxStyle where CheckBox == Image {
    /// Initializes a CheckBoxStyle for Image-based checkboxes.
    ///
    /// - Parameters:
    ///   - on: Image to display for the "on" state.
    ///   - off: Image to display for the "off" state.
    ///   - configuration: The configuration settings for the checkbox.
    public init(on: Image, off: Image, configuration: Configuration = .init()) {
        self.init(viewConfiguration: configuration) { $0 ? on : off }
    }
}

/// Represents a checkbox with rounded stroke overlay.
struct RoundedStrokeIconCheckBox: View {
    let icon: Image?
    let iconColor: Color
    let size: CGSize
    let backgroundColor: Color
    let stroke: RoundedStroke

    var body: some View {
        backgroundColor
            .frame(size: size)
            .overlay(ifLet: icon) { $0.foregroundColor(iconColor) }
            .transition(.identity)
            .overlay(if: true) { stroke }
            .cornerRadius(stroke.cornerRadius)
    }
}

/// Preview provider for CheckBoxStyle.
struct CheckBoxStyle_Preview: PreviewProvider {
    static var previews: some View {
        VStack {
            StatePreview(initial: false) {
                Toggle("My check box", isOn: $0)
                    .foregroundColor(.blue)
                    .toggleStyle(CheckBoxStyle(iconColor: .white))
            }
            .padding()

            StatePreview(initial: false) {
                Toggle("My check box", isOn: $0)
                    .foregroundColor(.blue)
                    .toggleStyle(
                        CheckBoxStyle(
                            iconColor: .white,
                            configuration: .init(layout: .vertical())
                        )
                    )
            }
            .padding()
        }
        .background(Color.black)
    }
}
