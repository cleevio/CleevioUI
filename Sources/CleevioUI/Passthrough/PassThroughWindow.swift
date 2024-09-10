//
//  PassThroughWindow.swift
//
//
//  Created by Lukáš Valenta on 22.06.2023.
//

#if canImport(UIKit) && !os(watchOS)
import UIKit

public final class PassThroughWindow: UIWindow {
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
}
#endif
