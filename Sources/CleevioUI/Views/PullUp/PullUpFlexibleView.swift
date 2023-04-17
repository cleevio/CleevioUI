//
//  PullUpFlexibleView.swift
//  
//
//  Created by Thành Đỗ Long on 07.07.2022.
//

import SwiftUI

@available(*, deprecated, message: "Quite laggy solution, consider using FloatingPanelRouter that has very similar functionality with much better performance")
public struct PullUpFlexibleView<Content: View>: View {
    private let content: Content
    private let supportedPositions: [PullUpFlexiblePosition]
    private let appereance: Appereance
    private let onBackgroundTap: (() -> Void)?
    @State private var verticalOffset: CGFloat = 0
    @State private var currentPosition: PullUpFlexiblePosition
    @GestureState private var dragState: DragState = .inactive

    public init(supportedPositions: [PullUpFlexiblePosition],
                initialPosition: PullUpFlexiblePosition,
                appereance: Appereance = .init(),
                onBackgroundTap: (() -> Void)? = nil,
                @ViewBuilder content: () -> Content) {
        self.supportedPositions = supportedPositions
        self.appereance = appereance
        _currentPosition = State(initialValue: initialPosition)
        self.onBackgroundTap = onBackgroundTap
        self.content = content()
    }

    public var body: some View {
        ZStack {
            Rectangle()
                .fill(appereance.backgroundColor.opacity(getOverlayOpacity()))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(dragState.isDragging ? nil : .default, value: dragState.isDragging)
                .onTapGesture(perform: {
                   onBackgroundTap?()
                    let minPosition = PullUpFlexiblePosition.minPosition(from: supportedPositions)
                    currentPosition = minPosition
                })

            VStack(spacing: 0) {
                Rectangle()
                    .fill(appereance.pullUpColor)
                    .frame(width: appereance.pullUpWidth, height: appereance.pullUpHeight)
                    .padding(.vertical, appereance.paddingForRectanglePullUp)
                    .cornerRadius(appereance.pullUpCornerRadius)
                    .opacity(0.1)

                self.content
                    .frame(
                        width: UIScreen.main.bounds.width,
                        height: getScrollViewHeight(),
                        alignment: .top
                    )
            }
            .frame(width: UIScreen.main.bounds.width,
                   height: UIScreen.main.bounds.height,
                   alignment: .top)
            .background(appereance.bottomsheetColor)
            .clipShape(CornerRadiusShape(radius: appereance.cornerRadius, corners: [.topLeft, .topRight]))
            .shadow(radius: appereance.shadowRadius)
            .offset(y: getOffset())
            .animation(dragState.isDragging ? nil : appereance.dragAnimation,
                       value: dragState.isDragging)
            .gesture(DragGesture()
                .updating($dragState) { value, state, _ in
                    state = .dragging(translation: value.translation)
                }
                .onEnded(onDragEnded)
            )
        }
        .edgesIgnoringSafeArea(.all)
    }

   struct CornerRadiusShape: Shape {
        var radius = CGFloat.infinity
        var corners = UIRectCorner.allCorners

        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            return Path(path.cgPath)
        }
    }

    private func getOffset() -> CGFloat {
        let topPositionOffset = PullUpFlexiblePosition.maxPosition(from: supportedPositions).offset
        let translation = dragState.isDragging ? (dragState.translation.height * -1) : verticalOffset
        let offsetWhileDragging = currentPosition.offset - translation
        let didUserReachTop = offsetWhileDragging <= topPositionOffset
        return didUserReachTop ? topPositionOffset : offsetWhileDragging
    }

    private func onDragEnded(drag: DragGesture.Value) {
        let verticalVelocity = drag.predictedEndLocation.y - drag.location.y
        let userIsSwipingUp = verticalVelocity < 0
        let isFastSwipe = abs(verticalVelocity) > 200

        let topEdgeLocation = currentPosition.offset + drag.translation.height
        let positionAbove = PullUpFlexiblePosition.abovePosition(
            from: supportedPositions,
            currentPosition: currentPosition
        )
        let positionBelow = PullUpFlexiblePosition.belowPosition(
            from: supportedPositions,
            currentPosition: currentPosition
        )
        let closestPosition: PullUpFlexiblePosition

        if (topEdgeLocation - positionAbove.offset) < (positionBelow.offset - topEdgeLocation) {
            closestPosition = positionAbove
        } else {
            closestPosition = positionBelow
        }

        if isFastSwipe {
            if userIsSwipingUp {
                currentPosition = positionAbove
            } else {
                currentPosition = positionBelow
            }
        } else {
            currentPosition = closestPosition
        }
    }

    private func getOverlayOpacity() -> Double {
        let translation = dragState.isDragging ? (dragState.translation.height * -1) : verticalOffset
        let offsetWhileDragging = currentPosition.offset - translation
        let maxPositionOffset = PullUpFlexiblePosition.maxPosition(from: supportedPositions).offset

        guard offsetWhileDragging > maxPositionOffset else { return 0.5 }

        let middlePositionOffset = PullUpFlexiblePosition.middlePosition(from: supportedPositions).offset
        let progressDistance = middlePositionOffset - offsetWhileDragging
        let span = middlePositionOffset - maxPositionOffset
        let progress = progressDistance / span
        return progress <= 0 ? 0 : Double(progress) * 0.5
    }

    private func getScrollViewHeight() -> CGFloat {
        let translation = dragState.isDragging ? (dragState.translation.height * -1) : verticalOffset
        let offsetWhileDragging = currentPosition.offset - translation

        return UIScreen.main.bounds.height -
        offsetWhileDragging -
        appereance.pullUpHeight -
        (appereance.paddingForRectanglePullUp * 2)
    }
}

public extension PullUpFlexibleView {
    struct Appereance {
        public var pullUpColor: Color
        public var pullUpWidth: CGFloat
        public var pullUpHeight: CGFloat
        public var pullUpCornerRadius: CGFloat
        public var paddingForRectanglePullUp: CGFloat

        public var backgroundColor: Color
        public var bottomsheetColor: Color
        public var cornerRadius: CGFloat
        public var shadowRadius: CGFloat

        public var dragAnimation: Animation?

        public init(pullUpColor: Color = Color.black,
            pullUpWidth: CGFloat = 40,
            pullUpHeight: CGFloat = 6,
            pullUpCornerRadius: CGFloat = 3,
            paddingForRectanglePullUp: CGFloat = 10,
            backgroundColor: Color = .black,
            bottomsheetColor: Color = .white,
            cornerRadius: CGFloat = 30,
            shadowRadius: CGFloat = 20,
            dragAnimation: Animation? = .interpolatingSpring(stiffness: 300, damping: 30)) {
            self.pullUpColor = pullUpColor
            self.pullUpWidth = pullUpWidth
            self.pullUpHeight = pullUpHeight
            self.pullUpCornerRadius = pullUpCornerRadius
            self.paddingForRectanglePullUp = paddingForRectanglePullUp
            self.backgroundColor = backgroundColor
            self.bottomsheetColor = bottomsheetColor
            self.cornerRadius = cornerRadius
            self.shadowRadius = shadowRadius
            self.dragAnimation = dragAnimation
        }
    }
}


struct PullUpFlexibleView_Previews: PreviewProvider {
    static var previews: some View {
        let positions: [PullUpFlexiblePosition] = [.init(screenPercentage: 0.5, type: .min),
                                                   .init(screenPercentage: 0.9, type: .max)]
        return PullUpFlexibleView(supportedPositions: positions,
                                  initialPosition: positions.first!) {
            Text("Hello world")
        }
    }
}
