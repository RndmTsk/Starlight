//
//  AnimatedNode.swift
//  Starlight
//
//  Created by Terry Latanville on 2019-05-17.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import SpriteKit

public class AnimationNode: SKSpriteNode {
    // MARK: - Constants
    private struct Constants {
        static let timePerFrame = 1/60.0
    }

    // MARK: - Properties
    public let textures: [SKTexture]
    public private(set) var isAtStart = true
    public private(set) var isAnimating = false
    public private(set) var currentAction: SKAction?
    private var animationQueue: [() -> Void] = []

    // MARK: - Lifecycle Functions
    public init(textures: [SKTexture], size: CGSize) {
        precondition(textures.count > 0, "AnimationNode must have at least one texture!")
        self.textures = textures

        super.init(texture: textures[0], color: .clear, size: size)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions
    public func animate(completion: @escaping () -> Void) { // TODO: (TL) Make this not look sucky when stopping mid-animation
        // Common completion block
        guard !isAnimating else {
            animationQueue.append(completion)
            return
        }

        let actionComplete: () -> Void = { [unowned self] in
            self.isAtStart = !self.isAtStart
            self.currentAction = nil
            self.isAnimating = false
            completion()

            if let nextAnimation = self.animationQueue.popLast() {
                self.animate(completion: nextAnimation)
            }
        }

        isAnimating = true
        if currentAction != nil {
            self.isAtStart = !self.isAtStart
            currentAction = currentAction!.reversed()
            run(currentAction!, completion: actionComplete)
        } else {
            currentAction = .animate(with: textures, timePerFrame: Constants.timePerFrame)
            if !isAtStart {
                currentAction = currentAction!.reversed()
            }
            run(currentAction!, completion: actionComplete)
        }
    }
}

