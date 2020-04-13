//
//  EnemyNode.swift
//  Starlight
//
//  Created by Terry Latanville on 2019-05-17.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import SpriteKit
import SpriteKitUtils

class EnemyNode: ParallaxGameObject {
    // MARK: - <Updatable>
    override func update(deltaTime: CFTimeInterval, multiplier: CGFloat) {
        isPaused = multiplier < CGFloat.ulpOfOne
        super.update(deltaTime: deltaTime, multiplier: multiplier)
    }

    // MARK: - <Collidable>
    override func didBeginCollision(with other: SKNode?) {
        guard other is PlayerNode else { return }
        run(.fadeOut(withDuration: 0.1)) {
            self.removeFromParent()
        }
    }
}

