//
//  GameUI.swift
//  Starlight
//
//  Created by Terry Latanville on 2019-05-16.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import SpriteKit
import SpriteKitUtils
import ResourceKit
import GameUIKit

protocol GameUIDelegate {
    func onDodgeTapped(_ state: Bool, direction: GameUI.DodgeDirection)
    func onMovement(_ delta: CGPoint)
    func onRestartSelected()
    func onExitSelected()
    func onSettingsSelected()
    func onContextToggled(at index: Int, selected: Bool)
}

class GameUI: UIElement {

    // MARK: - Enums
    enum DodgeDirection {
        case up
        case down
    }

    // MARK: - Constants
    static let ZPosition: CGFloat = 1000

    // MARK: - Properties
    let atlas: SKTextureAtlas
    let size: CGSize
    let movementEndThreshold: CGFloat
    let dodgeEndThreshold: CGFloat
    let boostStartThreshold: CGFloat
    var delegate: GameUIDelegate?
    var lastTouchLocation: CGPoint = .zero
    var isGamePaused = false
    var score: UInt = 0
    let overlayBackgroundColor = SKColor(red: 0, green: 0, blue: 0, alpha: 0.8)

    // MARK: - UI Elements
    var healthBar: ProgressBar!
    var boostBar: ProgressBar!
    var scoreLabel: Label!
    var movementHint: SKSpriteNode!
    var boostHint: SKSpriteNode!
    var contextMenuButton: Button!
    var contextMenu: ContextUI!
    var pauseMenuButton: Button!
    var pauseMenu: PauseUI!
    var gameOverUI: GameOverUI!
    var hasOverlay: Bool {
        return ((pauseMenu != nil && pauseMenu.parent != nil) ||
            (contextMenu != nil && contextMenu.parent != nil) ||
            (gameOverUI != nil && gameOverUI.parent != nil))
    }

    // MARK: - Lifecycle Functions
    init(atlasNamed atlasName: String, size: CGSize) {
        self.atlas = ResourceManager.shared.atlas(named: atlasName)
        self.size = size
        self.movementEndThreshold = size.width / 4
        self.dodgeEndThreshold = size.width / 2
        self.boostStartThreshold = movementEndThreshold * 3

        super.init()
        layoutUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions
    func boost(for amount: CGFloat) {
        boostBar.updateProgress(by: amount)
    }

    func setBoost(to value: CGFloat) {
        let delta = value - boostBar.progress
        boostBar.updateProgress(by: delta)
    }

    func setHealth(to value: CGFloat) {
        let delta = value - healthBar.progress
        healthBar.updateProgress(by: delta)
    }

    private func layoutUI() {
        isUserInteractionEnabled = true
        zPosition = GameUI.ZPosition

        let barSize = CGSize(width: 200, height: 26)

        // Health Bar
        healthBar = ProgressBar(bgTexture: atlas.textureNamed("healthunderlay"), fgTexture: atlas.textureNamed("healthoverlay"), size: barSize, startValue: 0, finishValue: 3, startsCompleted: true)
        healthBar.anchorPoint = CGPoint(x: 0.5, y: 1)
        healthBar.position = CGPoint(x: size.width / 2 - 153, y: size.height + 2)
        healthBar.zPosition = zPosition + 1
        addChild(healthBar)

        // Boost Bar
        boostBar = ProgressBar(bgTexture: atlas.textureNamed("boostunderlay"), fgTexture: atlas.textureNamed("boostoverlay"), size: barSize, startValue: 0, finishValue: 100, startsCompleted: true, direction: .left)
        boostBar.anchorPoint = CGPoint(x: 0.5, y: 1)
        boostBar.position = CGPoint(x: size.width / 2 + 153, y: size.height + 2)
        boostBar.zPosition = zPosition + 1
        addChild(boostBar)

        // Score Bar
        scoreLabel = Label(texture: atlas.textureNamed("scoreboard"), color: .clear, size: CGSize(width:160, height: 40), text: "0 pts")
        scoreLabel.anchorPoint = CGPoint(x: 0.5, y: 1)
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height)
        scoreLabel.zPosition = zPosition + 1003
        scoreLabel.fontName = AppDelegate.fontName
        scoreLabel.fontSize = 18
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.textLabel.position.x += 40
        scoreLabel.textLabel.position.y += 1
        addChild(scoreLabel)

        let buttonSize = CGSize(width:48, height: 48)
        let buttonColors: [Button.State : SKColor] = [
            .normal : SKColor(red: 0, green: 0, blue: 0, alpha: 0.1),
            .selected : SKColor(red: 0, green: 0, blue: 0, alpha: 0.1),
            .disabled : SKColor(red: 0, green: 0, blue: 0, alpha: 0.1)]

        // Flybits Menu Button
        let contextButtonTextures: [Button.State : SKTexture] = [
            .normal   : atlas.textureNamed("contextbutton"),
            .selected : atlas.textureNamed("contextbutton_glow"),
            .disabled : atlas.textureNamed("contextbutton")
        ]

        contextMenuButton = Button(size: buttonSize, colors: buttonColors, textures: contextButtonTextures, cornerRadius: 2)
        contextMenuButton.anchorPoint = CGPoint(x: 0, y: 1)
        contextMenuButton.position = CGPoint(x: 0, y: size.height)
        contextMenuButton.zPosition = zPosition + 1
        contextMenuButton.delegate = self
        addChild(contextMenuButton)

        // Pause Menu Button
        let pauseButtonTextures: [Button.State: SKTexture] = [
            .normal   : atlas.textureNamed("pausebutton"),
            .selected : atlas.textureNamed("pausebutton_glow"),
            .disabled : atlas.textureNamed("pausebutton")
        ]

        pauseMenuButton = Button(size: buttonSize, colors: buttonColors, textures: pauseButtonTextures, cornerRadius: 2)
        pauseMenuButton.anchorPoint = CGPoint(x: 1, y: 1)
        pauseMenuButton.position = CGPoint(x: size.width, y: size.height)
        pauseMenuButton.zPosition = zPosition + 1
        pauseMenuButton.delegate = self
        addChild(pauseMenuButton)

        // Tutorial Areas
        let textureSize = CGSize(width:movementEndThreshold, height: size.height)

        let moveGradientStart = CIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
        let moveGradientEnd = CIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        let moveTexture = SKTexture(size: textureSize, color1: moveGradientStart, color2: moveGradientEnd, direction: .left)
        movementHint = SKSpriteNode(texture: moveTexture, color: .clear, size: textureSize)
        movementHint.position = CGPoint(x: textureSize.width / 2, y: size.height / 2)

        let movementTutorialSize = CGSize(width:56, height: 320)
        let movementTutorial = SKSpriteNode(texture: atlas.textureNamed("tutorial_arrow"), color: .clear, size: movementTutorialSize)
        movementHint.addChild(movementTutorial)

        addChild(movementHint)
        /*
         let dodgeUpStrokeColor = SKColor(red: 1, green: 1, blue: 0, alpha: 0.8)
         let dodgeUpFillColor = SKColor(red: 1, green: 1, blue: 0, alpha: 0.1)
         let dodgeUpHighlight = Utils.RectShapeNode(CGRectMake(movementEndThreshold, 0, movementEndThreshold, size.height / 2), strokeColor: dodgeUpStrokeColor, fillColor: dodgeUpFillColor)
         // addChild(dodgeUpHighlight)

         let dodgeDownStrokeColor = SKColor(red: 1, green: 153/255.0, blue: 51/255.0, alpha: 0.8)
         let dodgeDownFillColor = SKColor(red: 1, green: 153/255.0, blue: 51/255.0, alpha: 0.1)
         let dodgeDownHighlight = Utils.RectShapeNode(CGRectMake(movementEndThreshold, size.height / 2, movementEndThreshold, size.height / 2), strokeColor: dodgeDownStrokeColor, fillColor: dodgeDownFillColor)
         // addChild(dodgeDownHighlight)
         */
        let boostGradientStart = CIColor(red: 0, green: 237/255.0, blue: 1.0, alpha: 0.5)
        let boostGradientEnd = CIColor(red: 0, green: 237/255.0, blue: 1.0, alpha: 0.0)
        let boostTexture = SKTexture(size: textureSize, color1: boostGradientStart, color2: boostGradientEnd, direction: .left)
        boostHint = SKSpriteNode(texture: boostTexture, color: .clear, size: textureSize)
        boostHint.position = CGPoint(x: size.width - textureSize.width / 2, y: size.height / 2)

        let boostTutorial = SKSpriteNode(texture: atlas.textureNamed("tutorial_turbo"), color: .clear, size: movementTutorialSize)
        boostHint.addChild(boostTutorial)

        addChild(boostHint)

        showHotZoneHints()
    }

    func showHotZoneHints() {
        let fadeInAction = SKAction.fadeIn(withDuration: 1.0)
        let fadeOutAction = SKAction.fadeOut(withDuration: 1.0)
        let waitAction = SKAction.wait(forDuration: 2)
        movementHint.run(.sequence([fadeInAction, waitAction, fadeOutAction]))
        boostHint.run(.sequence([fadeInAction, waitAction, fadeOutAction]))
    }

    func showGameOverScreen() {
        isGamePaused = true
        if gameOverUI == nil {
            gameOverUI = GameOverUI(atlasNamed: "UI", color: overlayBackgroundColor, size: size)
            gameOverUI.position = CGPoint(x: size.width / 2, y: size.height / 2)
            gameOverUI.zPosition = zPosition + 5000
            gameOverUI.delegate = self
        }
        gameOverUI.alpha = 0
        addChild(gameOverUI!)
        gameOverUI.run(.fadeAlpha(to: 1, duration: 0.2))
        contextMenuButton.run(.fadeOut(withDuration: 0.2))
        pauseMenuButton.run(.fadeOut(withDuration: 0.2))
    }

    // MARK: - User Interaction
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        parent?.touchesBegan(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        parent?.touchesMoved(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        parent?.touchesEnded(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
         parent?.touchesCancelled(touches, with: event)
    }
}

// MARK: - <UITouchDelegate>
extension GameUI: UITouchDelegate {
    func onTouchUp(_ sender: UIElement) {
        if sender == pauseMenuButton {
            isGamePaused = true
            if pauseMenu == nil {
                pauseMenu = PauseUI(atlasNamed: "UI", color: overlayBackgroundColor, size: size)
                pauseMenu.position = CGPoint(x: size.width / 2, y: size.height / 2)
                pauseMenu.zPosition = zPosition + 5000
                pauseMenu.delegate = self
            }
            pauseMenu.alpha = 0
            addChild(pauseMenu)
            pauseMenu.run(.fadeAlpha(to: 1, duration: 0.2))
            contextMenuButton.run(.fadeOut(withDuration: 0.2))
            pauseMenuButton.run(.fadeOut(withDuration: 0.2))
        } else if sender == contextMenuButton {
            isGamePaused = true
            if contextMenu == nil {
                contextMenu = ContextUI(atlasNamed: "UI", color: overlayBackgroundColor, size: size)
                contextMenu.position = CGPoint(x: size.width / 2, y: size.height / 2)
                contextMenu.zPosition = zPosition + 5000
                contextMenu.delegate = self
            }
            contextMenu.alpha = 0
            addChild(contextMenu)
            contextMenu.run(.fadeAlpha(to: 1, duration: 0.2))
            contextMenuButton.run(.fadeOut(withDuration: 0.2))
            pauseMenuButton.run(.fadeOut(withDuration: 0.2))
        }
    }
}

// MARK: - <Updatable>
extension GameUI: Updatable {
    func update(deltaTime: CFTimeInterval, multiplier: CGFloat) {
        if !isGamePaused {
            score += UInt(round(1 * multiplier))
            scoreLabel.textLabel.text = "\(score) pts"
        }
    }
}

// MARK: - <PauseScreenDelegate>
extension GameUI: PauseScreenDelegate {
    func onPauseScreenClosed(_ action: PauseUI.Action) {
        isGamePaused = false
        switch action {
        case .restart:
            delegate?.onRestartSelected()
        case .exit:
            delegate?.onExitSelected()
        case .settings:
            delegate?.onSettingsSelected()
        default:
            break // Do nothing for .Close
        }
        contextMenuButton.run(.fadeIn(withDuration: 0.2))
        pauseMenuButton.run(.fadeIn(withDuration: 0.2))
        showHotZoneHints()
    }
}

// MARK: - <ContextScreenDelegate>
extension GameUI: ContextScreenDelegate {
    func onContextToggled(at index: Int, selected: Bool) {
        delegate?.onContextToggled(at: index, selected: selected)
    }
    func onContextScreenClosed() {
        isGamePaused = false
        contextMenuButton.run(.fadeIn(withDuration: 0.2))
        pauseMenuButton.run(.fadeIn(withDuration: 0.2))
        showHotZoneHints()
    }
}

// MARK: - <GameOverScreenDelegate>
extension GameUI: GameOverScreenDelegate {
    func onGameOverScreenClosed(with action: GameOverUI.Action) {
        switch action {
        case .restart:
            delegate?.onRestartSelected()
        case .exit:
            delegate?.onExitSelected()
        }
        contextMenuButton.run(.fadeIn(withDuration: 0.2))
        pauseMenuButton.run(.fadeIn(withDuration: 0.2))
    }
}
