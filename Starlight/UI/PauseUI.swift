//
//  PauseUI.swift
//  Starlight
//
//  Created by Terry Latanville on 2019-05-16.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import SpriteKit
import GameUIKit
import ResourceKit

protocol PauseScreenDelegate {
    func onPauseScreenClosed(_ action: PauseUI.Action)
}

final class PauseUI: UIPanel {
    // MARK: - Enums
    enum Action {
        case close
        case restart
        case exit
        case settings
    }

    // MARK: - Properties
    var atlas: SKTextureAtlas
    var delegate: PauseScreenDelegate?

    // MARK: - UI Elements
    var closeButton: Button!
    var restartButton: Button!
    var exitButton: Button!
    var settingsButton: Button!

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
    init(atlasNamed name: String, color: SKColor, size: CGSize, baseTextureName: String? = nil) {
        self.atlas = ResourceManager.shared.atlas(named: name)
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
            .normal   : .clear,
            .selected : SKColor(red: 1, green: 1, blue: 1, alpha: 0.2),
            .disabled : .clear
        ]

        // Close Button
        let closeButtonTextures: [Button.State: SKTexture] = [
            .normal   : atlas.textureNamed("cancelbutton"),
            .selected : atlas.textureNamed("cancelbutton"),
            .disabled : atlas.textureNamed("cancelbutton")]

        closeButton = Button(size: CGSize(width:48, height: 48), colors: buttonColors, textures: closeButtonTextures, cornerRadius: 2)
        closeButton.anchorPoint = CGPoint(x: 0, y: 1)
        closeButton.position = CGPoint(x: -size.width / 2 + 5, y: size.height / 2 - 5)
        closeButton.zPosition = zPosition + 1
        closeButton.delegate = self
        addChild(closeButton)

        let buttonSize = CGSize(width:size.width, height: 80)
        // Restart Button
        restartButton = Button(size: buttonSize, colors: buttonColors, textures: nil, text: "RESTART")
        restartButton.position = CGPoint(x: 0, y: 80)
        restartButton.zPosition = zPosition + 1
        restartButton.delegate = self
        addChild(restartButton)

        // Exit Button
        exitButton = Button(size: buttonSize, colors: buttonColors, textures: nil, text: "EXIT")
        exitButton.position = .zero
        exitButton.zPosition = zPosition + 1
        exitButton.delegate = self
        addChild(exitButton)

        // Settings Button
        settingsButton = Button(size: buttonSize, colors: buttonColors, textures: nil, text: "SETTINGS")
        settingsButton.position = CGPoint(x: 0, y: -80)
        settingsButton.zPosition = zPosition + 1
        settingsButton.delegate = self
        addChild(settingsButton)
    }
}

// MARK: - <UITouchDelegate>
extension PauseUI: UITouchDelegate {
    func onTouchUp(_ sender: UIElement) {
        if sender == closeButton {
            delegate?.onPauseScreenClosed(.close)
        } else if sender == restartButton {
            delegate?.onPauseScreenClosed(.restart)
        } else if sender == exitButton {
            delegate?.onPauseScreenClosed(.exit)
        } else if sender == settingsButton {
            delegate?.onPauseScreenClosed(.settings)
        }
        run(.fadeAlpha(to: 0, duration: 0.2)) {
            self.removeFromParent()
        }
    }
}
