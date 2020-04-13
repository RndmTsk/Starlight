//
//  CGSize+Math.swift
//  MathKit
//
//  Created by Terry Latanville on 2019-05-16.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import CoreGraphics

public extension CGSize {
    static func *(left: CGSize, right: CGFloat) -> CGSize {
        return CGSize(width:left.width * right, height: left.height * right)
    }

    static func *=(left: inout CGSize, right: CGFloat) {
        left.width *= right
        left.height *= right
    }

    static func /(left: CGSize, right: CGFloat) -> CGSize {
        return CGSize(width:left.width / right, height: left.height / right)
    }

    static func /=(left: inout CGSize, right: CGFloat) {
        left.width /= right
        left.height /= right
    }
}
