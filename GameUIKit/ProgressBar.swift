//
//  ProgressBar.swift
//  Starlight
//
//  Created by Terry Latanville on 2019-05-16.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import SpriteKit

public final class ProgressBar: SKSpriteNode { // TODO: (TL) add support for colors
    public enum Direction {
        case up
        case down
        case right
        case left
    }

    // MARK: - Properties
    public let foreground: SKSpriteNode
    public let cropNode: SKCropNode
    public let fgMask: SKSpriteNode
    public let direction: Direction
    public var progress: CGFloat
    public var startValue: CGFloat { // TODO: (TL) Do we update progress to keep it proportionally filled?
        didSet {
            if progress < startValue {
                progress = startValue
            }
        }
    }
    public var finishValue: CGFloat {
        didSet {
            if progress > finishValue {
                progress = finishValue
            }
        }
    }

    public override var anchorPoint: CGPoint {
        didSet {
            let offsetDelta = CGPoint(x: oldValue.x - anchorPoint.x, y: oldValue.y - anchorPoint.y)
            for child in children {
                child.position.x += offsetDelta.x * size.width
                child.position.y += offsetDelta.y * size.height
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
    public init(bgTexture: SKTexture, fgTexture: SKTexture, size: CGSize, startValue: CGFloat, finishValue: CGFloat, startsCompleted: Bool = false, direction: Direction = .right) {
        self.startValue = startValue
        self.finishValue = finishValue
        self.direction = direction
        self.progress = startsCompleted ? self.finishValue : self.startValue

        // Set up the mask
        self.foreground = SKSpriteNode(texture: fgTexture, size: size)
        self.fgMask = SKSpriteNode(texture: fgTexture, size: size)
        self.cropNode = SKCropNode()
        self.cropNode.addChild(self.foreground)
        self.cropNode.maskNode = fgMask

        super.init(texture: bgTexture, color: .clear, size: size)
        self.cropNode.zPosition = zPosition + 1

        addChild(cropNode)

        animateProgress()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions
    public func updateProgress(by amount: CGFloat) {
        if abs(amount) < CGFloat.ulpOfOne {
            return
        }

        progress = max(min(progress + amount, finishValue), startValue)
        animateProgress()
    }

    private func animateProgress() {
        let progressPercent = 1 - (progress - startValue) / (finishValue - startValue)
        switch direction {
        case .up:
            fgMask.position.y = size.height * progressPercent
        case .down:
            fgMask.position.y = -size.width * progressPercent
        case .right:
            fgMask.position.x = size.width * progressPercent
        case .left:
            fgMask.position.x = -size.width * progressPercent
        }
    }
}
