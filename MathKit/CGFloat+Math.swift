//
//  CGFloat+Math.swift
//  MathKit
//
//  Created by Terry Latanville on 2019-05-17.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import Foundation
import struct CoreGraphics.CGFloat

public extension CGSize {
    func rounded() -> CGSize {
        return CGSize(width: width.rounded(), height: height.rounded())
    }

    mutating func round() { // TODO: (TL) FloatingPointRule?
        width.round()
        height.round()
    }
}
