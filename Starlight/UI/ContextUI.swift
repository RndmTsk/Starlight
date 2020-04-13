//
//  ContextUI.swift
//  Starlight
//
//  Created by Terry Latanville on 2019-05-16.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import SpriteKit
import GameUIKit
import ResourceKit

protocol ContextScreenDelegate: class {
    func onContextToggled(at index: Int, selected: Bool)
    func onContextScreenClosed()
}

final class ContextUI: UIPanel {
    // MARK: - Constants
    private enum Context: String, CaseIterable {
        case time = "Time"
        case boost = "Boost"
        case location = "Location"
        case weather = "Weather"
        case gyro = "Gyro"
    }

    // MARK: - Properties
    private var atlas: SKTextureAtlas
    public weak var delegate: ContextScreenDelegate?

    // MARK: - UI Elements
    var closeButton: Button!
    var titleLabel: Label!
    var contextButtons: [Button] = []

    override var anchorPoint: CGPoint {
        didSet {
            let offsetDelta = CGPoint(x: oldValue.x - anchorPoint.x, y: oldValue.y - anchorPoint.y)
            for child in children {
                child.position.x += offsetDelta.x * size.width
                child.position.y += offsetDelta.y * size.height
            }
        }
    }

    override var zPosition: CGFloat {
        didSet {
            let offsetDelta = zPosition - oldValue
            for child in children {
                child.zPosition += offsetDelta
            }
        }
    }

    // MARK: - Lifecycle Functions
    init(atlasNamed atlasName: String, color: SKColor, size: CGSize, baseTextureName: String? = nil) {
        self.atlas = ResourceManager.shared.atlas(named: atlasName)
        if let baseTextureName = baseTextureName {
            super.init(texture: atlas.textureNamed(baseTextureName), color: color, size: size)
        } else {
            super.init(texture: nil, color: color, size: size)
        }

        layoutUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions
    func layoutUI() {
        let buttonColors: [Button.State: SKColor] = [
            .normal : .clear,
            .selected : SKColor(red: 1, green: 1, blue: 1, alpha: 0.2),
            .disabled : .clear
        ]

        // Close Button
        let closeButtonTextures: [Button.State: SKTexture] = [
            .normal : atlas.textureNamed("cancelbutton"),
            .selected : atlas.textureNamed("cancelbutton"),
            .disabled : atlas.textureNamed("cancelbutton")
        ]

        closeButton = Button(size: CGSize(width:48, height: 48), colors: buttonColors, textures: closeButtonTextures, cornerRadius: 2)
        closeButton.anchorPoint = CGPoint(x: 0, y: 1)
        closeButton.position = CGPoint(x: -size.width / 2 + 5, y: size.height / 2 - 5)
        closeButton.zPosition = zPosition + 1
        closeButton.delegate = self
        addChild(closeButton)

        // Active Context Label
        titleLabel = Label(texture: nil, color: .clear, size: CGSize(width:size.width * 0.8, height: 25), text: "Active Context")
        titleLabel.anchorPoint = CGPoint(x: 0.5, y: 1)
        titleLabel.position = CGPoint(x: 0, y: size.height / 2 - 20)
        titleLabel.fontSize = 18
        titleLabel.zPosition = zPosition + 1
        addChild(titleLabel)

        let buttonSize = CGSize(width:50, height: 50) // Inset on each size = button width / 2
        let widthBetweenButtons = (size.width - buttonSize.width) / CGFloat(Context.allCases.count)
        let initialOffset = widthBetweenButtons / 2 + buttonSize.width / 2
        // Context Buttons
        for (index, context) in Context.allCases.enumerated() {
            let contextName = context.rawValue
            let textures: [Button.State: SKTexture] = [
                .normal : atlas.textureNamed("\(contextName)_dark"),
                .selected : atlas.textureNamed(contextName),
                .disabled : atlas.textureNamed(contextName)
            ]

            let contextButtonX = (-size.width / 2) + (initialOffset + CGFloat(index) * widthBetweenButtons)
            let contextButton = Button(size: buttonSize, colors: nil, textures: textures, cornerRadius: 2)
            contextButton.position = CGPoint(x: contextButtonX, y: 0)
            contextButton.zPosition = zPosition + 1
            contextButton.isToggle = true
            contextButton.delegate = self
            addChild(contextButton)

            contextButtons.append(contextButton)
        }
    }
}

// MARK: - <UITouchDelegate>
extension ContextUI: UITouchDelegate {
    func onTouchUp(_ sender: UIElement) {
        if sender == closeButton {
            delegate?.onContextScreenClosed()
            run(.fadeAlpha(to: 0, duration: 0.2)) {
                self.removeFromParent()
            }
        } else if let buttonNode = sender as? Button {
            if let contextIndex = contextButtons.firstIndex(of: buttonNode) {
                delegate?.onContextToggled(at: contextIndex, selected: buttonNode.isSelected)
            }
        }
    }
}
