//
//  ChargingEnemyNode.swift
//  Starlight
//
//  Created by Terry Latanville on 2019-05-17.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import SpriteKit

class ChargingEnemyNode: EnemyNode {
    // MARK: - Properties
    let detectionRadius: CGFloat = 150
    var isCharging = false
    var playerPosition: CGPoint = .zero
    var chargeDirection: CGVector = .zero

    // MARK: - Lifecycle Functions
    override func update(deltaTime: CFTimeInterval, multiplier: CGFloat) {
        let movementDelta = movementSpeed * CGFloat(deltaTime) * multiplier

        super.update(deltaTime: deltaTime, multiplier: multiplier)
        playerPosition = scene?.childNode(withName: PlayerNode.Constants.defaultName)?.position ?? .zero // TODO: (TL) There has to be a better way

        guard playerPosition != .zero else { return }

        let direction = CGVector(dx: playerPosition.x - position.x, dy: playerPosition.y - position.y)
        if !isCharging && direction.magnitude < detectionRadius {
            charge(in: direction)
        } else if isCharging {
            position.x += movementDelta * chargeDirection.dx
            position.y += movementDelta * chargeDirection.dy
        }
    }

    // MARK: - Functions
    func charge(in direction: CGVector) {
        isCharging = true
        chargeDirection = direction.normalized
    }
}

