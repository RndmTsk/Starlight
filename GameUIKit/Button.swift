//
//  Button.swift
//  Starlight
//
//  Created by Terry Latanville on 2019-05-16.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import SpriteKit

public final class Button: SKSpriteNode { // TODO: (TL) Label alignment, text size, etc.
    public enum State {
        case normal
        case selected
        case disabled
    }

    // MARK: - Properties
    public var textures: [State : SKTexture]?
    public var colors: [State : SKColor]?
    public var labelNode: SKLabelNode?
    public var backgroundNode: SKShapeNode?
    public var delegate: UITouchDelegate?
    public var isToggle: Bool = false
    public var isDisabled: Bool {
        didSet {
            self.isUserInteractionEnabled = !isDisabled
            if let textures = textures, let texture = textures[.disabled] {
                self.texture = texture
            }
            if let color = colors?[.disabled] {
                backgroundNode?.strokeColor = color
                backgroundNode?.fillColor = color
            }
        }
    }
    public var isSelected: Bool {
        didSet {
            let state: State
            if isDisabled {
                state = .disabled
            } else if isSelected {
                state = .selected
            } else {
                state = .normal
            }
            if let texture = textures?[state] {
                self.texture = texture
            }
            if let color = colors?[state] {
                backgroundNode?.fillColor = color
            }
        }
    }
    override public var anchorPoint: CGPoint {
        didSet {
            let offsetDelta = CGPoint(x: oldValue.x - anchorPoint.x, y: oldValue.y - anchorPoint.y)
            for child in children {
                child.position.x += offsetDelta.x * size.width
                child.position.y += offsetDelta.y * size.height
            }
        }
    }

    override public var zPosition: CGFloat {
        didSet {
            let offsetDelta = zPosition - oldValue
            for child in children {
                child.zPosition += offsetDelta
            }
        }
    }

    private var state: State = .normal
    public init(size: CGSize, colors: [State : SKColor]? = nil, textures: [State : SKTexture]? = nil, cornerRadius: CGFloat = 0, text: String? = nil) {
        self.textures = textures
        self.colors = colors
        self.isSelected = false
        self.isDisabled = false

        super.init(texture: textures?[.normal], color: .clear, size: size)
        self.isUserInteractionEnabled = true

        if let color = colors?[.normal] {
            let rect = CGRect(x: -size.width / 2, y:  -size.height / 2, width: size.width, height: size.height)
            let path = cornerRadius > 0 ? CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil) : CGPath(rect: rect, transform: nil)
            self.backgroundNode = SKShapeNode(path: path)
            self.backgroundNode!.strokeColor = .clear
            self.backgroundNode!.fillColor = color
            self.backgroundNode!.zPosition = self.zPosition - 1
            addChild(self.backgroundNode!)
        }

        if let text = text {
            self.labelNode = SKLabelNode(text: text)
            self.labelNode!.verticalAlignmentMode = .center
            self.labelNode!.zPosition = self.zPosition + 1

            addChild(self.labelNode!)
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Utility Functions
    public func isTouchInside(_ touch: UITouch?) -> Bool {
        if self.parent == nil || touch == nil {
            return false
        }

        let touchPoint = touch!.location(in: self.parent!)
        return frame.contains(touchPoint)
    }

    // MARK: - Interactive Functions
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isTouchInside(touches.first) {
            if !isToggle {
                isSelected = true
            }
            delegate?.onTouchDown(self)
        }
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isToggle {
            isSelected = isTouchInside(touches.first)
        }
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isTouchInside(touches.first) {
            isSelected = isToggle ? !isSelected : false
            delegate?.onTouchUp(self)
        }
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isSelected = isToggle ? !isSelected : false
        delegate?.onTouchCancelled(self)
    }
}
