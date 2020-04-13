//
//  AnimatedSpriteNode.swift
//  Starlight
//
//  Created by Terry Latanville on 2019-05-17.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import SpriteKit
import ResourceKit

open class AnimatedSpriteNode: SKSpriteNode, Updatable {
    // MARK: - Properties
    public let animationNames: [String]?
    public private(set) var animationDictionary: [String: AnimationNode] = [:]

    // MARK: - Lifecycle Functions
    public init(atlas: SKTextureAtlas, baseTextureName: String, size: CGSize, animationNames: [String]? = nil) {
        self.animationNames = animationNames

        super.init(texture: atlas.textureNamed(baseTextureName), color: .clear, size: size)

        addAnimations(from: atlas)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions
    open func update(deltaTime: CFTimeInterval, multiplier: CGFloat) { /* Do nothing */ }

    public func addAnimations(from atlas: SKTextureAtlas) {
        if let animationNames = animationNames {
            for animationName in animationNames {
                let textures = ResourceManager.shared.textures(from: atlas, named: animationName)
                let animationLayer = AnimationNode(textures: textures, size: size)
                animationDictionary[animationName] = animationLayer
                // TODO: (TL) Animation layers zPosition
                animationLayer.zPosition = 2
                addChild(animationLayer)
            }
        }
    }

    public func hasAnimation(named name: String) -> Bool {
        return (animationNames != nil && animationNames?.contains(name) != nil)
    }

    open func doAnimation(named name: String, completion: ((Bool) -> Void)? = nil) {
        if !hasAnimation(named: name) {
            return
        }

        if !animationDictionary[name]!.isAnimating {
            animationDictionary[name]!.animate { [unowned self] in
                completion?(self.animationDictionary[name]!.isAtStart)
            }
        }
    }
}
