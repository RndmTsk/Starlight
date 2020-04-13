//
//  Collidable.swift
//  Starlight
//
//  Created by Terry Latanville on 2019-05-17.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import SpriteKit

public protocol Collidable {
    func didBeginCollision(with other: SKNode?)
    func didEndCollision(with other: SKNode?)
}

public extension Collidable {
    func didBeginCollision(with other: SKNode?) { /* Do nothing */ }
    func didEndCollision(with other: SKNode?) { /* Do nothing */ }
}
