//
//  ParallaxTemplate.swift
//  SpriteKitUtils
//
//  Created by Terry Latanville on 2019-05-17.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import SpriteKit

public class ParallaxTemplate: NodeGenerator.Template {
    public var direction: ParallaxDirection
    public init(baseTextureName: String,
                size: CGSize,
                speed: CGFloat,
                spawnRate: CFTimeInterval,
                colliderType: UInt32,
                idleAction: SKAction,
                direction: ParallaxDirection = .left,
                animationNames: [String]? = nil) {
        self.direction = direction
        super.init(baseTextureName: baseTextureName,
                   size: size,
                   speed: speed,
                   spawnRate: spawnRate,
                   colliderType: colliderType,
                   idleAction: idleAction,
                   animationNames: animationNames)
    }
}

