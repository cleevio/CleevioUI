//
//  ClearBackgroundUIHostingController.swift
//
//
//  Created by Lukáš Valenta on 22.06.2023.
//

import Foundation
#if canImport(UIKit) && !os(watchOS)
import SwiftUI

open class ClearBackgroundUIHostingController<Content: View>: UIHostingController<Content> {
    open override func loadView() {
        super.loadView()
        view.backgroundColor = .clear
    }
}
#endif
