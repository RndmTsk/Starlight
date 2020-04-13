//
//  PlayerNode.swift
//  Starlight
//
//  Created by Terry Latanville on 2019-05-17.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import SpriteKit
import SpriteKitUtils
import MathKit

typealias BoostRecovery = CGFloat
typealias BoostDepletion = CGFloat

fileprivate extension BoostRecovery {
    static let lowRecovery: CGFloat = 0.04
    static let mediumRecovery: CGFloat = 0.1
    static let highRecovery: CGFloat = 0.16
    static let veryHighRecovery: CGFloat = 0.2
}

fileprivate extension BoostDepletion {
    static let lowDepletion: CGFloat = 0.1
    static let mediumDepletion: CGFloat = 0.2
    static let highDepletion: CGFloat = 0.32
    static let veryHighDepletion: CGFloat = 0.4
}

final class PlayerNode: AnimatedSpriteNode {
    // MARK: - Constants
    struct Constants {
        static let defaultName = "Player"
        fileprivate static let emitterPath = Bundle.main.path(forResource: "PropulsionEmitter", ofType: "sks")!
    }

    // MARK: - Properties
    let boostMax: CGFloat
    let healthMax: CGFloat = 4
    var isBoosting: Bool {
        return self.currentSpeed > 1
    }
    var shield: SKSpriteNode!
    var jetEmitters: [SKEmitterNode] = []
    var currentSpeed: CGFloat = 1
    var initialPosition: CGPoint = .zero
    var targetPosition: CGPoint?
    var healthValue: CGFloat
    var movementSpeed: CGFloat = 1
    var boostValue: CGFloat
    var boostDepletionRate: CGFloat
    var boostRecoveryRate: CGFloat

    // MARK: - Lifecycle Functions
    override init(atlas: SKTextureAtlas, baseTextureName: String, size: CGSize, animationNames: [String]? = nil) {
        self.healthValue = healthMax
        self.boostMax = 100
        self.boostValue = boostMax
        self.boostDepletionRate = .mediumDepletion
        self.boostRecoveryRate = .mediumRecovery

        super.init(atlas: atlas, baseTextureName: baseTextureName, size: size, animationNames: animationNames)
        self.name = Constants.defaultName

        addPhysics()
        addShield(atlas.textureNamed("shield"))
        addJets()

        run(.repeatForever(.bobSequence))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func update(deltaTime: CFTimeInterval, multiplier: CGFloat) {
        super.update(deltaTime: deltaTime, multiplier: multiplier)
        isPaused = multiplier < CGFloat.ulpOfOne

        if isBoosting && boostValue > CGFloat.ulpOfOne {
            boostValue = max(0, boostValue - boostDepletionRate)
        } else if isBoosting {
            boost(start: false)
        } else if !isBoosting && boostValue < boostMax {
            boostValue = min(boostMax, boostValue + boostRecoveryRate)
        }
        /*
         if targetPosition == nil {
         return
         }

         let movementDelta = movementSpeed * CGFloat(deltaTime) * multiplier
         let distance = targetPosition!.y - position.y
         if abs(distance) < movementDelta {
         position.y = targetPosition!.y
         targetPosition = nil
         } else {
         position.y += distance * CGFloat(deltaTime) * multiplier
         }
         */
    }

    // MARK: - Functions
    func updateBoost(boostTrigger: String) {
        if boostTrigger.hasSuffix("1") {
            boostDepletionRate = .veryHighDepletion
            boostRecoveryRate = .lowRecovery
        } else if boostTrigger.hasSuffix("2") {
            boostDepletionRate = .highDepletion
            boostRecoveryRate = .mediumRecovery
        } else if boostTrigger.hasSuffix("3") {
            boostDepletionRate = .mediumDepletion
            boostRecoveryRate = .mediumRecovery
        } else if boostTrigger.hasSuffix("4") {
            boostDepletionRate = .mediumDepletion
            boostRecoveryRate = .highRecovery
        } else if boostTrigger.hasSuffix("5") {
            boostDepletionRate = .lowDepletion
            boostRecoveryRate = .veryHighRecovery
        }
    }
    func boost(start: Bool = true) {
        guard !start || boostValue > CGFloat.ulpOfOne else { return }

        guard hasAnimation(named: "boost") else { return }

        if (start && animationDictionary["boost"]!.isAtStart) ||
            (!start && !animationDictionary["boost"]!.isAtStart){
            currentSpeed = isBoosting ? 1 : 2
            speed = isBoosting ? 2 : 1
            doAnimation(named: "boost")
        }
    }

    override func doAnimation(named name: String, completion: ((Bool) -> Void)? = nil) {
        guard hasAnimation(named: name) else { return }

        animationDictionary[name]!.animate {
            if self.animationDictionary[name]!.isAtStart {
                self.jetEmitters[1].run(.fadeOut(withDuration: 1))
                self.jetEmitters[2].run(.fadeOut(withDuration: 1))
            } else {
                if self.jetEmitters[1].parent == nil {
                    self.addChild(self.jetEmitters[1])
                }
                if self.jetEmitters[2].parent == nil {
                    self.addChild(self.jetEmitters[2])
                }
                self.jetEmitters[1].run(.fadeIn(withDuration: 1))
                self.jetEmitters[2].run(.fadeIn(withDuration: 1))
            }
            completion?(self.animationDictionary[name]!.isAtStart)
        }
    }

    override func move(toParent parent: SKNode) {
        super.move(toParent: parent)
        for jetEmitter in jetEmitters {
            jetEmitter.targetNode = parent
        }
    }
    private func addPhysics() {
        let radius = max(size.width, size.height) / 2
        physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody!.friction = 0
        physicsBody!.linearDamping = 0
        physicsBody!.angularDamping = 0
        physicsBody!.categoryBitMask = .player
        physicsBody!.contactTestBitMask = .enemy | .collectible
    }

    private func addShield(_ texture: SKTexture) {
        shield = SKSpriteNode(texture: texture, color: .clear, size: size * 1.5)
        shield.zPosition = 2
        addChild(shield)
    }

    private func createJetEmitter(at position: CGPoint, withZIndex zPosition: CGFloat) -> SKEmitterNode {
        let jetEmitter = NSKeyedUnarchiver.unarchiveObject(withFile: Constants.emitterPath) as! SKEmitterNode
        jetEmitter.position = position
        jetEmitter.zPosition = zPosition

        return jetEmitter
    }

    private func addJets() {
        let jetEmitter = createJetEmitter(at: CGPoint(x: 11, y: 7), withZIndex: 1)

        jetEmitters.append(jetEmitter)
        jetEmitters.append(createJetEmitter(at: CGPoint(x: 20, y: 13), withZIndex: 3))
        jetEmitters.append(createJetEmitter(at: CGPoint(x: 20, y: -10), withZIndex: 3))

        addChild(jetEmitter)
    }

    private func collected(_ collectible: ParallaxGameObject) {
        print("Picked up coin!")
        collectible.run(.fadeOut(withDuration: 0.1)) {
            collectible.removeFromParent()
        }
        if healthValue < healthMax {
            healthValue += 1
        }
        if healthValue == 2 {
            addChild(shield)
        }
    }

    private func collided(with enemy: EnemyNode) {
        let flickerOut: SKAction = .fadeAlpha(to: 0.1, duration: 0.2)
        let flickerIn: SKAction = .fadeAlpha(to: 1.0, duration: 0.2)

        healthValue -= 1 // TODO: (TL) Re-enable this
        if healthValue < 1 {
            healthValue = 0.1
            run(flickerOut) {
                self.removeFromParent()
                self.healthValue = 0
            }
        } else if healthValue < 2 {
            shield.run(flickerOut) {
                self.shield.removeFromParent()
            }
        }
        if shield.parent != nil {
            shield.run(.sequence([flickerOut, flickerIn, flickerOut, flickerIn])) {
                self.run(.moveBy(x: self.initialPosition.x - self.position.x, y: 0, duration: 1.0))
            }
        }
    }
}

// MARK: - <Collidable>
extension PlayerNode: Collidable {
    func didBeginCollision(with other: SKNode?) {
        guard let other = other,
            let otherPhysicsBody = other.physicsBody
            else { return }
        if (otherPhysicsBody.categoryBitMask & .enemy) > 0 {
            collided(with: other as! EnemyNode)
        } else if (otherPhysicsBody.categoryBitMask & .collectible) > 0 {
            collected(other as! CollectibleNode)
        }
    }
}
