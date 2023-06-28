//
//  PassThroughView.swift
//
//
//  Created by Lukáš Valenta on 22.06.2023.
//

#if canImport(UIKit)
import UIKit

public final class PassThroughView: UIView {
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
}
#endif
