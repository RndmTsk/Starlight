//
//  GameObject.swift
//  Starlight
//
//  Created by Terry Latanville on 2019-05-17.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import SpriteKit

open class ParallaxGameObject: AnimatedSpriteNode, Collidable {
    public let categoryType: UInt32
    public let colliderType: UInt32
    public let direction: ParallaxDirection
    public var screenSize: CGSize
    public var movementSpeed: CGFloat

    // MARK: - Lifecycle Functions
    public init(atlas: SKTextureAtlas, template: ParallaxTemplate, screenSize: CGSize) {
        self.categoryType = template.categoryType
        self.colliderType = template.colliderType
        self.direction = template.direction
        self.screenSize = screenSize
        self.movementSpeed = template.speed

        super.init(atlas: atlas, baseTextureName: template.baseTextureName, size: template.size, animationNames: template.animationNames)

        addPhysics()
        resetPosition()
        run(.repeatForever(template.idleAction))
        if let animationName = template.animationNames?[0] {
            doAnimation(named: animationName)
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions
    open override func update(deltaTime: CFTimeInterval, multiplier: CGFloat) {
        let movementDelta = movementSpeed * CGFloat(deltaTime) * multiplier
        switch direction {
        case .up:
            position.y += movementDelta
            if position.y > screenSize.height + size.height {
                removeFromParent()
            }
        case .down:
            position.y -= movementDelta
            if position.y < -size.height {
                removeFromParent()
            }
        case .right:
            position.x += movementDelta
            if position.x > screenSize.width + size.width {
                removeFromParent()
            }
        case .left:
            position.x -= movementDelta
            if position.x < -size.width {
                removeFromParent()
            }
        }
        super.update(deltaTime: deltaTime, multiplier: multiplier)
    }

    private func addPhysics() {
        let radius = max(size.width, size.height) / 2
        physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody!.friction = 0
        physicsBody!.linearDamping = 0
        physicsBody!.angularDamping = 0
        physicsBody!.categoryBitMask = categoryType
        physicsBody!.contactTestBitMask = colliderType
    }

    private func resetPosition() {
        let randomAmount: CGFloat = CGFloat.random(in: 0..<6) / 10
        let offsetAmount: CGFloat = 0.2 // 1 - (RandomAmountMax / 2)
        switch direction {
        case .up:
            position = CGPoint(x: randomAmount * screenSize.width + screenSize.width * offsetAmount, y: -size.height)
        case .down:
            position = CGPoint(x: randomAmount * screenSize.width + screenSize.width * offsetAmount, y: screenSize.height + size.height)
        case .right:
            position = CGPoint(x: -size.width, y: randomAmount * screenSize.height + screenSize.height * offsetAmount)
        case .left:
            position = CGPoint(x: screenSize.width + size.width, y: randomAmount * screenSize.height + screenSize.height * offsetAmount)
        }
    }

    // MARK: - <Collidable>
    open func didBeginCollision(with other: SKNode?) { /* Subclasses to provide implementation */ }
    open func didEndCollision(with other: SKNode?)  { /* Subclasses to provide implementation */ }
}
