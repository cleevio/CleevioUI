import SwiftUI

fileprivate struct Seg: Selectable {
    var id: String { title }
    let title: String
    var color: Color = .clear
}

struct SegmentedControlPreviews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            if #available(iOS 14.0, *) {
                StatePreview(initial: Seg(title: "Option1")) { binding in
                    SegmentedControl(
                        segments: [
                            Seg(title: "Option1"),
                            Seg(title: "Option2")
                        ],
                        selection: binding,
                        configuration: .init(scroll: .ifNeeded, indicatorTransition: .swap(.opacity)),
                        indicatorConfiguration: .init(fill: Color.pink)
                    )
                }

                StatePreview(initial: Seg(title: "Option1")) { binding in
                    SegmentedControl(
                        segments: [
                            Seg(title: "Option1"),
                            Seg(title: "Option2"),
                            Seg(title: "Option3"),
                            Seg(title: "Option4"),
                            Seg(title: "Option5"),
                            Seg(title: "Option6"),
                        ],
                        selection: binding,
                        configuration: .init(scroll: .never(minimumScaleFactor: 0.3), indicatorTransition: .slide(.bouncy)),
                        indicatorConfiguration: .init(fill: Color.pink)
                    )
                }

                StatePreview(initial: Seg(title: "Option1")) { binding in
                    SegmentedControl(
                        segments: [
                            Seg(title: "Option1"),
                            Seg(title: "Option2"),
                            Seg(title: "Option3"),
                            Seg(title: "Option4"),
                            Seg(title: "Option5"),
                            Seg(title: "Option6"),
                        ],
                        selection: binding,
                        configuration: .init(scroll: .ifNeeded, indicatorTransition: .slide(.bouncy)),
                        indicatorConfiguration: .init(fill: Color.pink)
                    )
                }

                StatePreview(initial: Seg(title: "Option1")) { binding in
                    SegmentedControl(
                        segments: [
                            Seg(title: "Option3"),
                            Seg(title: "Option1"),
                            Seg(title: "Option2")
                        ],
                        selection: binding,
                        configuration: .init(scroll: .never(minimumScaleFactor: 1.0), indicatorTransition: .slide(.bouncy)),
                        button: { action, segment in
                            Button(segment.title, action: action)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .frame(maxWidth: .infinity)
                        },
                        indicator: {
                            Color.yellow
                        }
                    )
                    .padding(3)
                    .background(Color.gray)
                    .padding(.horizontal, 24)
                }
            }
        }
    }
}

@available(iOS 14.0, *)
struct SegmentedTabViewPreviews: PreviewProvider {
    fileprivate static let segments = [
        Seg(title: "Option3", color: .red),
        Seg(title: "Option1", color: .green),
        Seg(title: "Option2", color: .blue)
    ]

    static var previews: some View {
        StatePreview(initial: Seg(title: "Option1")) { binding in
            SegmentedTabView(
                selection: binding,
                configuration: .init(),
                control: {
                    SegmentedControl(
                        segments: segments,
                        selection: binding,
                        indicatorConfiguration: .init(fill: .black)
                    )
                },
                content: {
                    ForEach(segments) {
                        $0.color.tag($0.id)
                    }
                }
            )
        }
    }
}
