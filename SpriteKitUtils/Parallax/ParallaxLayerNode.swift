//
//  ParallaxLayerNode.swift
//  SpriteKitUtils
//
//  Created by Terry Latanville on 2019-05-17.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import SpriteKit
import ResourceKit

public class ParallaxLayerNode: SKNode {
    private struct Constants {
        static let maxLayersPerNode: CGFloat = 5
    }

    // MARK: - Properties
    public let size: CGSize
    public let parallaxConfig: ParallaxNodeConfig
    public var background: SKSpriteNode?
    public var textures: [SKTexture]
    public var timeToNextItem: CFTimeInterval = 0
    public var averageDeltaTime: CFTimeInterval = 1/60.0
    public var totalOscillationOffset: CGFloat = 0
    public var oscillationDirection: CGFloat = 1
    public var oscillationOffset: CGFloat = 0
    public var oscillation: CGFloat

    public var nextAtlas: SKTextureAtlas? {
        didSet {
            if let nextAtlas = nextAtlas {
                textures = ResourceManager.shared.textures(from: nextAtlas, named: parallaxConfig.assetGroup)
            }
        }
    }

    public override var zPosition: CGFloat {
        didSet {
            let offsetDelta = zPosition - oldValue
            for child in children {
                child.zPosition += offsetDelta
            }
        }
    }

    // MARK: - Lifecycle Functions
    public init(textures: [SKTexture], size: CGSize, parallaxConfig: ParallaxNodeConfig) {
        self.textures = textures
        self.size = size
        self.parallaxConfig = parallaxConfig
        if case .center = parallaxConfig.anchor {
            self.oscillation = parallaxConfig.oscillation / 2
        } else {
            self.oscillation = parallaxConfig.oscillation
        }

        super.init()
        guard parallaxConfig.borderColor != .clear else { return }
        let backgroundSize: CGSize
        switch parallaxConfig.direction {
        case .up, .down:
            backgroundSize = CGSize(width: parallaxConfig.layerOffset, height: size.height)
        case .right, .left:
            backgroundSize = CGSize(width: size.width, height: parallaxConfig.layerOffset)
        }
        self.background = SKSpriteNode(color: parallaxConfig.borderColor, size: backgroundSize)
        switch parallaxConfig.anchor {
        case .top:
            self.background!.anchorPoint = CGPoint(x: 0.5, y: 1)
            self.background!.position = CGPoint(x: size.width / 2, y: size.height)
        case .center:
            // TODO: (TL) ... add to top and bottom
            break
        case .bottom:
            self.background!.anchorPoint = CGPoint(x: 0.5, y: 0)
            self.background!.position = CGPoint(x: size.width / 2, y: 0)
        }
        self.background!.zPosition = self.zPosition + 1
        addChild(self.background!)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions
    public func nextScreenElement() -> SKSpriteNode {
        let elementIndex = Int.random(in: 0..<textures.count)
        let newElement = SKSpriteNode(texture: textures[elementIndex], size: textures[elementIndex].size())
        newElement.position = startPosition(for: newElement)
        newElement.zPosition = parallaxConfig.distance * Constants.maxLayersPerNode
        if parallaxConfig.colorAdjustPct > CGFloat.ulpOfOne {
            newElement.color = parallaxConfig.colorAdjust
            newElement.colorBlendFactor = parallaxConfig.colorAdjustPct
        }
        return newElement
    }

    func updateOscillation(deltaTime: CFTimeInterval, multiplier: CGFloat) {
        totalOscillationOffset += oscillationDirection * oscillationOffset * multiplier
        if totalOscillationOffset > oscillation {
            totalOscillationOffset = oscillation
            oscillationDirection = -1
        } else {
            let lowerOscillationTarget = (parallaxConfig.anchor == .center) ? -oscillation : 0
            if totalOscillationOffset < lowerOscillationTarget {
                totalOscillationOffset = -oscillation
                oscillationDirection = 1
            }
        }
    }

    func updatePosition(child: SKSpriteNode, deltaTime: CGFloat, multiplier: CGFloat) {
        if parallaxConfig.oscillationSpeed > CGFloat.ulpOfOne {
            updateOscillationPosition(for: child, deltaTime: deltaTime, multiplier: multiplier)
        }

        guard child != self.background else { return } // Background doesn't move!

        switch parallaxConfig.direction {
        case .up:
            child.position.y += parallaxConfig.speed * deltaTime * multiplier
            if child.position.y + child.size.height > size.height {
                child.removeFromParent()
            }

        case .down:
            child.position.y -= parallaxConfig.speed * deltaTime * multiplier
            if child.position.y + child.size.height < 0 {
                child.removeFromParent()
            }

        case .right:
            child.position.x += parallaxConfig.speed * deltaTime * multiplier
            if child.position.x + child.size.width > size.width {
                child.removeFromParent()
            }

        case .left:
            child.position.x -= parallaxConfig.speed * deltaTime * multiplier
            if child.position.x + child.size.width < 0 {
                child.removeFromParent()
            }
        }
    }

    func updateOscillationPosition(for child: SKSpriteNode, deltaTime: CGFloat, multiplier: CGFloat) {
        let oscillationDelta = oscillationDirection * oscillationOffset * multiplier
        switch parallaxConfig.direction {
        case .up, .down:
            child.position.x += oscillationDelta
        case .right, .left:
            child.position.y += oscillationDelta
        }
    }

    // MARK: - Utilities
    func startPosition(for element: SKSpriteNode) -> CGPoint {
        var startPosition: CGPoint = .zero
        switch parallaxConfig.anchor {
        case .top:
            element.anchorPoint = CGPoint(x: 0.5, y: 1)
            startPosition.y = size.height - parallaxConfig.layerOffset
        case .center:
            let offsetMultiplier:CGFloat = CGFloat(arc4random_uniform(20)) * 0.1
            let offsetDirection: CGFloat = arc4random_uniform(2) < 1 ? -1 : 1
            let offset:CGFloat = offsetDirection * offsetMultiplier * parallaxConfig.layerOffset
            element.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            startPosition.y = size.height / 2 + offset
        case .bottom:
            element.anchorPoint = CGPoint(x: 0.5, y: 0)
            startPosition.y = parallaxConfig.layerOffset
        }

        switch parallaxConfig.direction {
        case .up, .down:
            startPosition.x = size.width / 2 + totalOscillationOffset
        case .left:
            startPosition.x = size.width + element.size.width
        case .right:
            startPosition.x = -element.size.width
            startPosition.y += totalOscillationOffset
        }

        return startPosition
    }
}

// MARK: - <Updatable>
extension ParallaxLayerNode: Updatable {
    public func update(deltaTime: CFTimeInterval, multiplier: CGFloat) {
        averageDeltaTime = max((averageDeltaTime + deltaTime) / 2, 1/60.0)

        if timeToNextItem > 0 {
            timeToNextItem -= deltaTime
        } else if children.count < parallaxConfig.maxItems {
            let pixelsPerUpdate = CFTimeInterval(parallaxConfig.speed) * averageDeltaTime
            let newElement = nextScreenElement()
            switch parallaxConfig.direction {
            case .up, .down:
                timeToNextItem = CFTimeInterval(newElement.size.height) * CFTimeInterval(1 + parallaxConfig.elementDelay) / pixelsPerUpdate * averageDeltaTime
            case .right, .left:
                timeToNextItem = CFTimeInterval(newElement.size.width) * CFTimeInterval(1 + parallaxConfig.elementDelay) / pixelsPerUpdate * averageDeltaTime
            }
            addChild(newElement)
        }

        if parallaxConfig.oscillationSpeed > CGFloat.ulpOfOne {
            updateOscillation(deltaTime: deltaTime, multiplier: multiplier)
        }
        let deltaTimeCGFloat = CGFloat(deltaTime)
        for case let child as SKSpriteNode in children {
            updatePosition(child: child, deltaTime: deltaTimeCGFloat, multiplier: multiplier)
        }
    }
}
