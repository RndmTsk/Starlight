//
//  GameOverUI.swift
//  Starlight
//
//  Created by Terry Latanville on 2019-05-16.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import SpriteKit
import GameUIKit
import ResourceKit

protocol GameOverScreenDelegate {
    func onGameOverScreenClosed(with action: GameOverUI.Action)
}

class GameOverUI: UIPanel {
    // MARK: - Enums
    enum Action {
        case restart
        case exit
    }

    // MARK: - Properties
    var atlas: SKTextureAtlas
    var delegate: GameOverScreenDelegate?

    // MARK: - UI Elements
    var gameOverLabel: Label!
    var restartButton: Button!
    var exitButton: Button!

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
            .normal : .clear,
            .selected : SKColor(red: 1, green: 1, blue: 1, alpha: 0.2),
            .disabled : .clear
        ]

        let buttonSize = CGSize(width: size.width, height: 80)
        // Game Over Label
        gameOverLabel = Label(texture: nil, color: .clear, size: buttonSize, text: "GAME OVER")
        gameOverLabel.position = CGPoint(x: 0, y: 100)
        gameOverLabel.zPosition = zPosition + 1
        addChild(gameOverLabel)

        // Restart Button
        restartButton = Button(size: buttonSize, colors: buttonColors, textures: nil, text: "RESTART")
        restartButton.position = .zero
        restartButton.zPosition = zPosition + 1
        restartButton.delegate = self
        addChild(restartButton)

        // Exit Button
        exitButton = Button(size: buttonSize, colors: buttonColors, textures: nil, text: "EXIT")
        exitButton.position = CGPoint(x: 0, y: -80)
        exitButton.zPosition = zPosition + 1
        exitButton.delegate = self
        addChild(exitButton)
    }
}


// MARK: - <UITouchDelegate>
extension GameOverUI: UITouchDelegate {
    func onTouchUp(_ sender: UIElement) {
        let action: Action = sender == restartButton ? .restart : .exit
        delegate?.onGameOverScreenClosed(with: action)
        run(.fadeAlpha(to: 0, duration: 0.2)) {
            self.removeFromParent()
        }
    }
}
