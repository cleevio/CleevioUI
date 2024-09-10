//
//  BaseUIViewControllerRepresentable.swift
//  
//
//  Created by Lukáš Valenta on 28.12.2022.
//

import SwiftUI

#if canImport(UIKit) && !os(watchOS)
public struct BaseUIViewControllerRepresentable: UIViewControllerRepresentable {
    public let viewController: UIViewController

    public init(viewController: UIViewController) {
        self.viewController = viewController
    }

    public func makeUIViewController(context: Context) -> some UIViewController {
        viewController
    }

    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}
#endif
