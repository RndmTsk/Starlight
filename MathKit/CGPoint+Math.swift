//
//  CGPoint+Math.swift
//  MathKit
//
//  Created by Terry Latanville on 2019-05-17.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import struct CoreGraphics.CGPoint

public extension CGPoint {
    static func *(_ lhs: CGPoint, _ scale: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x * scale, y: lhs.y * scale)
    }
}
