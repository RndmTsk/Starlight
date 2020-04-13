//
//  Updatable.swift
//  Starlight
//
//  Created by Terry Latanville on 2019-05-17.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import struct CoreGraphics.CFTimeInterval
import struct CoreGraphics.CGFloat

public protocol Updatable {
    func update(deltaTime: CFTimeInterval, multiplier: CGFloat)
}

