//
//  UIWindow+topViewController.swift
//
//
//  Created by Lukáš Valenta on 22.06.2023.
//

#if canImport(UIKit)
import UIKit

public extension UIWindow {
    var topViewController: UIViewController? {
        var top = rootViewController
        while true {
            if let presented = top?.presentedViewController {
                top = presented
            } else if let nav = top as? UINavigationController {
                top = nav.visibleViewController
            } else if let tab = top as? UITabBarController {
                top = tab.selectedViewController
            } else {
                break
            }
        }

        return top
    }
}
#endif
