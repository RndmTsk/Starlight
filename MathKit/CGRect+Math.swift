//
//  CGRect+Math.swift
//  MathKit
//
//  Created by Terry Latanville on 2019-05-17.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import struct CoreGraphics.CGRect
import struct CoreGraphics.CGFloat

public extension CGRect {
    static func *(_ lhs: CGRect, _ scale: CGFloat) -> CGRect {
        return CGRect(origin: lhs.origin * scale, size: lhs.size * scale)
    }
}
