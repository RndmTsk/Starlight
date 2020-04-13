//
//  RSUILabel.swift
//  Starlight
//
//  Created by Terry Latanville on 2019-05-16.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import SpriteKit

public final class Label: SKSpriteNode { // TODO: (TL) better support for vertical / horizontal alignment/
    // MARK: - Properties
    public let textLabel: SKLabelNode
    public var fontName: String? {
        didSet { textLabel.fontName = fontName }
    }
    public var fontColor: SKColor? {
        didSet { textLabel.fontColor = fontColor }
    }
    public var fontSize: CGFloat? {
        didSet { textLabel.fontSize = fontSize ?? 32 /* Default size of SKLabelNode */ }
    }
    public var verticalAlignmentMode: SKLabelVerticalAlignmentMode? {
        didSet {
            textLabel.verticalAlignmentMode = verticalAlignmentMode ?? .baseline
            switch textLabel.verticalAlignmentMode { // TODO: (TL) Take offset into account?
            case .baseline:
                textLabel.position.y = -size.height / 2 + textLabel.fontSize / 2 // TODO: (TL) Not correct
            case .bottom:
                textLabel.position.y = -size.height
            case .top:
                textLabel.position.y = 0
            case .center:
                textLabel.position.y = -size.height / 2
            @unknown default:
                fatalError()
            }
        }
    }
    public var horizontalAlignmentMode: SKLabelHorizontalAlignmentMode? {
        didSet { textLabel.horizontalAlignmentMode = horizontalAlignmentMode ?? .center }
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
    public init(texture: SKTexture?, color: SKColor, size: CGSize, text: String) {
        textLabel = SKLabelNode(text: text)
        textLabel.verticalAlignmentMode = .center
        fontSize = textLabel.fontSize

        super.init(texture: texture, color: color, size: size)
        textLabel.zPosition = zPosition + 1

        addChild(textLabel)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
