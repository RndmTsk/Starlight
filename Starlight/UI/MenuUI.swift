//
//  MenuUI.swift
//  Starlight
//
//  Created by Terry Latanville on 2019-05-16.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import SpriteKit
import GameUIKit
import MathKit
import ResourceKit

protocol MenuUIDelegate {
    func onStartTapped(state: Bool)
}

final class MenuUI: UIElement {
    // MARK: - Constants
    static let ZPosition: CGFloat = 1000

    // MARK: - Properties
    let atlas: SKTextureAtlas
    let size: CGSize
    var connectionCompleted: Bool {
        didSet {
            updateUIForConnection()
        }
    }
    var delegate: MenuUIDelegate?

    // MARK: - UI Elements
    var startButton: Button!
    var connectingLabel: Label!

    // MARK: - Lifecycle Functions
    init(atlasNamed name: String, size: CGSize) {
        self.atlas = ResourceManager.shared.atlas(named: name)
        self.size = size
        self.connectionCompleted = false

        super.init()

        isUserInteractionEnabled = true

        layoutUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions
    func layoutUI() {
        zPosition = MenuUI.ZPosition

        // Add Background Layers
        let backgroundSize = size
        let layer1 = SKSpriteNode(texture: atlas.textureNamed("background_1"), color: .clear, size: backgroundSize)
        addChild(layer1)

        let layer2 = SKSpriteNode(texture: atlas.textureNamed("background_2_planet"), color: .clear, size: backgroundSize * 1.2)
        layer2.position = CGPoint(x: backgroundSize.width * 0.20, y: -backgroundSize.height * 0.20)
        addChild(layer2)

        let layer3 = SKSpriteNode(texture: atlas.textureNamed("background_3"), color: .clear, size: backgroundSize)
        addChild(layer3)

        let layer4 = SKSpriteNode(texture: atlas.textureNamed("background_4"), color: .clear, size: backgroundSize)
        addChild(layer4)

        let elementSize = CGSize(width: 120, height: 30)

        // Start Button
        startButton = Button(size: size, colors: nil, textures: nil, text: "PLAY")
        startButton.position = .zero
        startButton.zPosition = zPosition + 1
        startButton.delegate = self
        startButton.isUserInteractionEnabled = false
        startButton.alpha = 0
        startButton.labelNode!.fontSize = 24
        addChild(startButton)

        // Connecting Label
        connectingLabel = Label(texture: nil, color: .clear, size: elementSize, text: "Starlight")
        connectingLabel.position = .zero
        connectingLabel.zPosition = zPosition + 1
        addChild(connectingLabel)
    }

    func updateUIForConnection() {
        let waitAction = SKAction.wait(forDuration: 2)
        let fadeOutAction = SKAction.fadeOut(withDuration: 1)
        let fadeInAction = SKAction.fadeIn(withDuration: 1)
        if connectionCompleted {
            connectingLabel.run(.sequence([waitAction, fadeOutAction])) {
                self.startButton.run(fadeInAction) {
                    self.startButton.isUserInteractionEnabled = true
                }
            }
        } else {
            startButton.run(fadeOutAction) {
                self.startButton.isUserInteractionEnabled = false
                self.connectingLabel.run(fadeInAction)
            }
        }
    }
}

// MARK: - <UITouchDelegate>
extension MenuUI: UITouchDelegate {
    func onTouchUp(_ sender: UIElement) {
        guard sender == startButton else { return }
        delegate?.onStartTapped(state: true)
    }
}
