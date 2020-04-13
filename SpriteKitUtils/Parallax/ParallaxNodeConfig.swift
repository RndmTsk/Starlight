//
//  ParallaxNodeConfig.swift
//  SpriteKitUtils
//
//  Created by Terry Latanville on 2019-05-17.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import SpriteKit

public enum ParallaxDirection {
    case up
    case down
    case right
    case left
}

public struct ParallaxNodeConfig {
    public enum Anchor {
        case top
        case bottom
        case center
    }

    public enum NodeType {
        case standard
        case oscillating
        case bordered
    }

    public let atlasName: String
    public let assetGroup: String
    public let speed: CGFloat
    public let distance: CGFloat
    public let maxItems: Int
    public let colorAdjust: SKColor
    public let colorAdjustPct: CGFloat
    public let anchor: Anchor
    public let layerOffset: CGFloat
    public let direction: ParallaxDirection
    public let oscillation: CGFloat
    public let oscillationSpeed: CGFloat
    public let elementDelay: CGFloat
    public let borderColor: SKColor

    public init(atlasName: String,
                assetGroup: String,
                speed: CGFloat,
                distance: CGFloat,
                maxItems: Int = 1,
                colorAdjust: SKColor = .clear,
                colorAdjustPct: CGFloat = 0,
                anchor: Anchor = .bottom,
                layerOffset: CGFloat = 0,
                direction: ParallaxDirection = .left,
                oscillation: CGFloat = 0,
                oscillationSpeed: CGFloat = 0,
                elementDelay: CGFloat = 0,
                borderColor: SKColor = .clear) {
        self.atlasName = atlasName
        self.assetGroup = assetGroup
        self.speed = speed
        self.distance = distance
        self.maxItems = maxItems
        self.colorAdjust = colorAdjust
        self.colorAdjustPct = colorAdjustPct
        self.anchor = anchor
        self.layerOffset = layerOffset
        self.direction = direction
        self.oscillation = oscillation
        self.oscillationSpeed = oscillationSpeed
        self.elementDelay = elementDelay
        self.borderColor = borderColor
    }
}
