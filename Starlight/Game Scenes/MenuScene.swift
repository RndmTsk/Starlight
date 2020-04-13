//
//  MenuScene.swift
//  Starlight
//
//  Created by Terry on 2015-09-01.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import SpriteKit

final class MenuScene: SKScene {
    // MARK: - Properties
    private var menuUI: MenuUI!

    // MARK: - Lifecycle Functions
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        self.size = view.frame.size
        self.isUserInteractionEnabled = true

        setupScene()
        menuUI.connectionCompleted = true // TOOD: (TL) Some other network connection?
    }

    // MARK: - Functions
    func setupScene() {
        menuUI = MenuUI(atlasNamed: "StartUI", size: size)
        menuUI.position = CGPoint(x: size.width / 2, y: size.height / 2)
        menuUI.delegate = self
        addChild(menuUI)
    }
}

// MARK: - <MenuUIDelegate>
extension MenuScene: MenuUIDelegate {
    func onStartTapped(state: Bool) {
        guard state else { return }
        let gameScene = GameScene(fileNamed: "GameScene")!
        let transition = SKTransition.doorsOpenHorizontal(withDuration: 0.5)
        view?.presentScene(gameScene, transition: transition)
    }
}
