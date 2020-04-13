//
//  ColliderTypes.swift
//  Starlight
//
//  Created by Terry Latanville on 2019-05-17.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

typealias ColliderType = UInt32

extension ColliderType {
    static let player: UInt32 = (1 << 0)
    static let enemy: UInt32 = (1 << 1)
    static let collectible: UInt32 = (1 << 2)
}
