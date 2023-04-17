//
//  CircularProgressBarStategy.swift
//
//  Created by Thành Đỗ Long on 06.12.2021.
//

import Combine
import CoreGraphics

open class CircularProgressBarStategy: ObservableObject {
    open var progressStart: CGFloat { 0.0 }
    open var progressEnd: CGFloat { 1.0 }
    
    @Published public var progressTo: CGFloat

    @Published public var title: String?
    
    public init(progressStart: CGFloat, title: String? = nil) {
        self.progressTo = progressStart
        self.title = title
    }
}


