//
//  CGVector+Math.swift
//  MathKit
//
//  Created by Terry Latanville on 2019-05-16.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import struct SpriteKit.CGVector

public extension CGVector {
    // TODO: (TL) Cache these
    var normalized: CGVector {
        let mag = magnitude
        if mag > 0 {
            return CGVector(dx: dx / mag, dy: dy / mag)
        }
        return CGVector(dx: 0, dy: 0)
    }

    var magnitude: CGFloat {
        return sqrt(dx * dx + dy * dy)
    }

    static func * (left: CGVector, right: CGFloat) -> CGVector {
        return CGVector(dx: left.dx * right, dy: left.dy * right)
    }
}

