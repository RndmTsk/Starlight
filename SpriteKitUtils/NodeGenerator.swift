//
//  GeneratorNode.swift
//  Starlight
//
//  Created by Terry Latanville on 2019-05-17.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import SpriteKit
import ResourceKit

open class NodeGenerator: SKNode {
    open class Template {
        // MARK: - Properties
        public let baseTextureName: String
        public let size: CGSize
        public let speed: CGFloat
        public let spawnRate: CFTimeInterval
        public let categoryType: UInt32
        public let colliderType: UInt32
        public let idleAction: SKAction
        public let animationNames: [String]?
        // private(set) var

        // MARK: - Computed Properties
        public var spawnRateUpperOffset: CFTimeInterval { // TODO: (TL) Avoid hard-coding?
            return 3
        }
        public var spawnRateLowerOffset: CFTimeInterval {
            return 1
        }

        // MARK: - Lifecycle Methods
        public init(baseTextureName: String,
                    size: CGSize,
                    speed: CGFloat,
                    spawnRate: CFTimeInterval,
                    colliderType: UInt32,
                    idleAction: SKAction,
                    animationNames: [String]? = nil) {
            self.baseTextureName = baseTextureName
            self.size = size
            self.speed = speed
            self.spawnRate = spawnRate
            self.categoryType = colliderType
            self.colliderType = colliderType
            self.idleAction = idleAction
            self.animationNames = animationNames
        }
    }
    // MARK: - Properties
    public let atlas: SKTextureAtlas
    public private(set) var screenSize: CGSize
    public private(set) var templates: [Int: Template]
    public private(set) var timers: [Int: CFTimeInterval] = [:]

    // MARK: - Lifecycle Functions
    public init(atlasName: String, templates: [Int: Template], screenSize: CGSize) {
        self.atlas = ResourceManager.shared.atlas(named: atlasName)
        self.screenSize = screenSize
        self.templates = templates

        super.init()
        for (index, template) in templates {
            timers[index] = template.spawnRate
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func generateElement(ofType: Int, withTemplate template: Template) -> SKNode? {
        // Intended to be extended by sub-classes
        return nil
    }

    private func randomOffset(upper: CFTimeInterval, lower: CFTimeInterval) -> CFTimeInterval {
        return ((CFTimeInterval.random(in: 0..<upper) + lower) * 0.1) + lower
    }
}

// MARK: - <Updatable>
extension NodeGenerator: Updatable {
    public func update(deltaTime: CFTimeInterval, multiplier: CGFloat) {
        for (type, timer) in timers {
            if timer < 0 {
                let template = templates[type]!
                timers[type] = template.spawnRate * randomOffset(upper: template.spawnRateUpperOffset, lower: template.spawnRateLowerOffset)
                if let element = generateElement(ofType: type, withTemplate: template) {
                    addChild(element)
                }
            } else {
                timers[type]! -= deltaTime * CFTimeInterval(multiplier)
            }
        }
        for case let updatableChild as Updatable in children {
            updatableChild.update(deltaTime: deltaTime, multiplier: multiplier)
        }
    }
}
