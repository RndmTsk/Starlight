//
//  GameScene.swift
//  Starlight
//
//  Created by Terry on 2015-08-24.
//  Copyright (c) 2015 Flybits Inc. All rights reserved.
//

import SpriteKit
import SpriteKitUtils
import ResourceKit

private extension Bool {
    static let off = false
    static let on = true
}

final class GameScene: SKScene {

    // MARK: - Constants
    private struct Constants {
        static let rainEmitterPath = Bundle.main.path(forResource: "RainEmitter", ofType: "sks")!
        static let snowEmitterPath = Bundle.main.path(forResource: "SnowEmitter", ofType: "sks")!
    }

    // MARK: - Properties
    private var playerNode: PlayerNode!
    var enemyGenerator: EnemyNodeGenerator!
    var collectibleGenerator: CollectibleNodeGenerator!
    var parallaxNode: ParallaxNode!
    var contextRuleNames = [String]()
    var contextRuleSubscriptions = [false, false, false, false, false]
    var lastTouchLocation: CGPoint = .zero
    var rainEmitter: SKEmitterNode!
    var snowEmitter: SKEmitterNode!
    var lastUpdateTime: CFTimeInterval = 0
    var lastAPIRequest: CFTimeInterval = 0
    var notificationQueue: OperationQueue!

    var zoneRequestTime: CFTimeInterval = 0

    // MARK: - UI Elements
    var gameUI: GameUI!
    
    // MARK: - Lifecyle Functions
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        self.size = view.frame.size
        self.isUserInteractionEnabled = true

        // TODO: (TL) TEMPORARY
        UIApplication.shared.isIdleTimerDisabled = true
        // TODO: (TL) TEMPORARY

        setupScene()
        // registerForContextChanges() // TODO: (TL)
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if playerNode.healthValue < CGFloat.ulpOfOne && !gameUI.isGamePaused {
            // Game Over!
            gameUI.isGamePaused = true
            gameUI.showGameOverScreen()
        }

        let deltaTime = lastUpdateTime > 0 ? (currentTime - lastUpdateTime) : 0
        let multiplier = gameUI.isGamePaused ? 0 : playerNode.currentSpeed

        // Update UI
        gameUI.setHealth(to: playerNode.healthValue)
        gameUI.setBoost(to: playerNode.boostValue)
        gameUI.update(deltaTime: deltaTime, multiplier: multiplier)

        // Update Game Objects
        playerNode.update(deltaTime: deltaTime, multiplier: multiplier)
        enemyGenerator.update(deltaTime: deltaTime, multiplier: multiplier)
        collectibleGenerator.update(deltaTime: deltaTime, multiplier: multiplier)
        parallaxNode.update(deltaTime: deltaTime, multiplier: multiplier)
/* TODO: (TL) Re-implement
        lastAPIRequest += deltaTime
        if lastAPIRequest > Constants.RuleRefreshRate && contextRuleSubscriptions.filter({ $0 } ).count > 0 {
            lastAPIRequest = 0
                ContextManager.sharedManager.refreshRules()
        }
 */
/*
        // TODO: (TL) TEMPORARY
        if lastUpdateTime > zoneRequestTime {
            zoneRequestTime = lastUpdateTime + (10 * 60) // 10 mins
            let query = ZonesQuery(limit: 1, offset: 0)
            ZoneRequest.Query(query) { (zones, pagination, error) in
                print("Retrieved Zones")
            }.execute()
        }
        // TODO: (TL) TEMPORARY
 */
        // Update the last time we did an update
        lastUpdateTime = currentTime
    }
    
    // MARK: - Functions
    func setupScene() {
        physicsWorld.contactDelegate = self
/*
        backgroundColor = .clear
        let backgroundGradient = SKTexture(size: size, color1: CIColor(red: 0, green: 0, blue: 0, alpha: 1), color2: CIColor(red: 1, green: 1, blue: 1, alpha: 1))
        let backgroundGradientSprite = SKSpriteNode(texture: backgroundGradient)
        backgroundGradientSprite.position = CGPoint(x: size.width / 2, size.height / 2)
        addChild(backgroundGradientSprite)
 */
        
        // Add player
        addPlayerNode()
        
        // Add enemy/obstacle Layer
        addEnemyGeneratorNode()

        // Add collectible layer
        addCollectibleGeneratorNode()

        // Add backgrounds (parallax and static)
        addBackgrounds()
        
        // Add UI
        gameUI = GameUI(atlasNamed: "UI", size: size)
        gameUI.delegate = self
        addChild(gameUI)
    }
    
    func addPlayerNode() {
        let shipAtlas = ResourceManager.shared.atlas(named: "Ship")
        playerNode = PlayerNode(atlas: shipAtlas, baseTextureName: "idle", size: CGSize(width:50, height: 50), animationNames: ["boost"])
        playerNode.zPosition = 0
        playerNode.position = CGPoint(x: size.width / 4, y: size.height / 2)
        playerNode.initialPosition = playerNode.position
        playerNode.xScale = -1
        
        addChild(playerNode)
    }
    
    func addEnemyGeneratorNode() {
        let enemySize = CGSize(width:40, height: 40)
        let enemyTemplates: [EnemyType: ParallaxTemplate] = [
            .basic : ParallaxTemplate(baseTextureName: "enemy_mine",
                                      size: enemySize,
                                      speed: 250,
                                      spawnRate: 0.8,
                                      colliderType: .enemy,
                                      idleAction: .bobSequence),
            .charger : ParallaxTemplate(baseTextureName: "enemy_flyer",
                                        size: enemySize,
                                        speed: 300,
                                        spawnRate: 5,
                                        colliderType: .enemy,
                                        idleAction: .bobSequence)
        ]

        enemyGenerator = EnemyNodeGenerator(templates: enemyTemplates, screenSize: size)
        enemyGenerator.zPosition = 0
        addChild(enemyGenerator)
    }

    func addCollectibleGeneratorNode() {
        let collectibleSize = CGSize(width:20, height: 20)
        let collectibleTemplates: [CollectibleType: ParallaxTemplate] = [
            .coin : ParallaxTemplate(baseTextureName: "point",
                                     size: collectibleSize,
                                     speed: 300,
                                     spawnRate: 15,
                                     colliderType: .collectible,
                                     idleAction: .bobSequence,
                                     animationNames: ["point"])
        ]
        collectibleGenerator = CollectibleNodeGenerator(templates: collectibleTemplates,
                                                        screenSize: size)
        collectibleGenerator.zPosition = 0
        addChild(collectibleGenerator)
    }
    
    func addBackgrounds() {
        let foregroundBorderColor = SKColor(red: 208/255.0, green: 100/255.0, blue: 90/255.0, alpha: 1.0)
        let backgroundBorderColor = SKColor(red: 88/255.0, green: 45/255.0, blue: 37/255.0, alpha: 1.0)

        // Add parallax backgrounds
        let parallaxConfig = [
            // Small
            // Large
            // PLAYER
            // ENEMY
            // OBSTACLE -> large, small, float
            // Float
            // Large
            // Sky

            // Small --v //
            ParallaxNodeConfig(atlasName: "Desert",
                               assetGroup: "ground_small",
                               speed: 781.25,
                               distance: 2,
                               maxItems: 1,
                               colorAdjust: .red,
                               colorAdjustPct: 0.2,
                               oscillation: 10,
                               oscillationSpeed: 2,
                               elementDelay: 0.2),
            // Large --v //
            ParallaxNodeConfig(atlasName: "Desert",
                               assetGroup: "ground_large",
                               speed: 625,
                               distance: 1,
                               maxItems: 3,
                               colorAdjust: .red,
                               colorAdjustPct: 0.1,
                               layerOffset: 10,
                               borderColor: foregroundBorderColor),

            // < Player >   //
            // < Enemy >    //
            // < Obstacle > // [ground_ ...]

            // Float --v //
            ParallaxNodeConfig(atlasName: "Desert",
                               assetGroup: "ground_float",
                               speed: 187.5,
                               distance: -1,
                               maxItems: 3,
                               colorAdjust: .black,
                               colorAdjustPct: 0.2,
                               anchor: .center,
                               layerOffset: 50),

            // Large --v //
            ParallaxNodeConfig(atlasName: "Desert",
                               assetGroup: "ground_large",
                               speed: 75,
                               distance: -2,
                               maxItems: 3,
                               colorAdjust: .black,
                               colorAdjustPct: 0.4,
                               layerOffset: 10,
                               borderColor: backgroundBorderColor),

            // Sky --v //
            ParallaxNodeConfig(atlasName: "Skybox",
                               assetGroup: "planet",
                               speed: 6.25,
                               distance: -3,
                               maxItems: 1,
                               anchor: .top)
        ]

        parallaxNode = ParallaxNode(nodeConfigs: parallaxConfig, size: size)
        addChild(parallaxNode)
    }

    // TODO: (TL) Re-implement
//    func registerForContextChanges() {
//        notificationQueue = NSOperationQueue()
//        notificationQueue.name = "com.flybits.starlight.notifications"
//        NSNotificationCenter.defaultCenter().addObserverForName(ContextManager.Constants.ContextRuleAdded, object: nil, queue: notificationQueue) { (notification) -> Void in
//            print("RULE ADDED: \(notification)")
//            if let rule = (notification.userInfo as? [String:FlybitsSDK.Rule])?[ContextManager.Constants.ContextRule], let ruleName = rule.name {
//                self.addContextRule(ruleName)
//                self.toggleContextChange(rule)
//            }
//        }
//        NSNotificationCenter.defaultCenter().addObserverForName(ContextManager.Constants.ContextRuleChanged, object: nil, queue: notificationQueue) { (notification) -> Void in
//            print("RULE CHANGED: \(notification)")
//            if let rule = (notification.userInfo as? [String:FlybitsSDK.Rule])?[ContextManager.Constants.ContextRule] {
//                self.toggleContextChange(rule)
//            }
//        }
//
//        let typesToRead: Set<HKObjectType> = Set(arrayLiteral: HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!)
//        HealthContextDataStore.sharedStore.authorizeHealthKitToShareTypes(nil, readTypes: typesToRead) { (authorized, error) -> Void in
//            guard authorized else {
//                print("[FAIL] HKHealthKit was not authorized!")
//                return
//            }
//            print("[ OK ] HKHealthKit was authorized!")
//
//            let _ = ContextManager.sharedManager.registerSDKContextProvider(.HealthKitSteps, priority: .Any, pollFrequency: 5 * 60, uploadFrequency: 5 * 60)
//        }
//        let _ = ContextManager.sharedManager.registerSDKContextProvider(.Network, priority: .Any, pollFrequency: 5 * 60, uploadFrequency: 5 * 60)
//        let _ = ContextManager.sharedManager.registerSDKContextProvider(.Carrier, priority: .Any, pollFrequency: 12 * 60 * 60, uploadFrequency: 12 * 60 * 60)
//        let _ = ContextManager.sharedManager.registerSDKContextProvider(.Language, priority: .Any, pollFrequency: 12 * 60 * 60, uploadFrequency: 12 * 60 * 60)
//        let _ = ContextManager.sharedManager.registerSDKContextProvider(.Availability, priority: .Any, pollFrequency: 12 * 60 * 60, uploadFrequency: 12 * 60 * 60)
//
//        ContextManager.sharedManager.startDataPolling()
//    }

    // TODO: (TL) Re-implement
//    func addContextRule(ruleName: String) {
//        if !contextRuleNames.contains(ruleName) {
//            contextRuleNames.append(ruleName)
//
//            let lowercaseRuleName = ruleName.lowercaseString
//            for (contextIndex, selected) in contextRuleSubscriptions.enumerated() {
//                let rulePrefix = Constants.contextIndexToRulePrefix(contextIndex)
//                if lowercaseRuleName.hasPrefix(rulePrefix) {
//                    ContextManager.sharedManager.updateRuleSubscription(ruleName, subscribe: selected)
//                }
//            }
//        }
//    }

    // TODO: (TL) Re-implement
//    func toggleContextChange(rule: FlybitsSDK.Rule) {
//        if rule.lastResult != nil && !rule.lastResult! {
//            return // TODO: (TL) Ignore rules that are false -- no, should this toggle things?
//        }
//
//        if let ruleName = rule.name {
//            let ruleIndex = Constants.rulePrefixToContextIndex(rulePrefix: Constants.Rules.Boost)
//            guard ruleIndex >= 0 && ruleIndex < contextRuleSubscriptions.count else {
//                return // Invalid rule or we're not using it yet
//            }
//            if ruleName.hasPrefix(Constants.Rules.Boost) && contextRuleSubscriptions[ruleIndex] {
//                // TODO: (TL) TEMPORARY --v
//                if ruleName.hasSuffix("5") || ruleName.hasSuffix("3") || ruleName.hasSuffix("1") {
//                    parallaxNode.switchAtlas("Tundra")
//                    toggleRain(false)
//                    toggleSnow(true)
//                } else {
//                    parallaxNode.switchAtlas("Lush")
//                    toggleSnow(false)
//                    toggleRain(true)
//                }
//                // TODO: (TL) TEMPORARY --^
//                playerNode.updateBoost(ruleName)
//            } else if ruleName.hasPrefix(Constants.Rules.Location) && contextRuleSubscriptions[ruleIndex] {
//                // TODO: (TL) Update Adding city?
//            } else if ruleName.hasPrefix(Constants.Rules.Weather) && contextRuleSubscriptions[ruleIndex] {
//                let newAtlasName = ruleName.componentsSeparatedByString(" ").last!
//                parallaxNode.switchAtlas(newAtlasName)
//                if newAtlasName == "Tundra" {
//                    toggleRain(.off)
//                    toggleSnow(.on)
//                } else if newAtlasName == "Lush" {
//                    toggleSnow(.off)
//                    toggleRain(.on)
//                } else {
//                    toggleRain(.off)
//                    toggleSnow(.off)
//                }
//            }
//        }
//    }

    func toggleRain(_ isRaining: Bool) {
        if isRaining {
            if rainEmitter == nil {
                rainEmitter = (NSKeyedUnarchiver.unarchiveObject(withFile: Constants.rainEmitterPath) as! SKEmitterNode)
                rainEmitter.particlePositionRange = CGVector(dx: size.width, dy: rainEmitter.particlePositionRange.dy)
                rainEmitter.position = CGPoint(x: size.width / 2, y: size.height)
                rainEmitter.zPosition = 70
            }
            rainEmitter.isPaused = false
            addChild(rainEmitter)
        } else {
            if rainEmitter != nil && rainEmitter.parent != nil {
                rainEmitter.removeFromParent()
                rainEmitter = nil
            }
        }
    }

    func toggleSnow(_ isSnowing: Bool) {
        if isSnowing {
            if snowEmitter == nil {
                snowEmitter = (NSKeyedUnarchiver.unarchiveObject(withFile: Constants.snowEmitterPath) as! SKEmitterNode)
                snowEmitter.particlePositionRange = CGVector(dx: size.width, dy: snowEmitter.particlePositionRange.dy)
                snowEmitter.position = CGPoint(x: size.width / 2, y: size.height)
                snowEmitter.zPosition = 70
            }
            snowEmitter.isPaused = false
            addChild(snowEmitter)
        } else {
            if snowEmitter != nil && snowEmitter.parent != nil {
                snowEmitter.removeFromParent()
                snowEmitter = nil
            }
        }
    }

    // MARK: - User Interaction Functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !gameUI.hasOverlay else { return }
        
        for touch in touches {
            let location = touch.location(in: self)
            if location.x > gameUI.boostStartThreshold {
                playerNode.boost()
            } else if location.x > gameUI.movementEndThreshold && location.x < gameUI.dodgeEndThreshold {
                // TODO: (TL) Dodge animations
                if location.y < size.height / 2 { // Dodge down
                    onDodgeTapped(true, direction: .up)
                } else { // Dodge up
                    onDodgeTapped(true, direction: .down)
                }
            } else if location.x < gameUI.movementEndThreshold {
                lastTouchLocation = location
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !gameUI.hasOverlay else { return }
        
        for touch in touches {
            let location = touch.location(in: self)
            if location.x > gameUI.dodgeEndThreshold && location.x < gameUI.boostStartThreshold && playerNode.isBoosting {
                playerNode.boost(start: false)
            } else if location.x > gameUI.dodgeEndThreshold && location.x > gameUI.boostStartThreshold && !playerNode.isBoosting {
                playerNode.boost()
            }
            
            if location.x < gameUI.movementEndThreshold {
                let movementDelta = CGPoint(x: lastTouchLocation.x - location.x, y: lastTouchLocation.y - location.y)
                onMovement(movementDelta)
                lastTouchLocation = location
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !gameUI.hasOverlay,
            hasTouchXComponent(overThreshold: gameUI.boostStartThreshold, in: touches)
            else { return }
        playerNode.boost(start: false)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !gameUI.hasOverlay,
            hasTouchXComponent(overThreshold: gameUI.boostStartThreshold, in: touches)
            else { return }
        playerNode.boost(start: false)
    }

    // TODO: (TL) Turn these into a single function that accepts a comparator
    private func hasTouchXComponent(overThreshold threshold: CGFloat, in touches: Set<UITouch>) -> Bool {
        return touches.first { $0.location(in: self).x > threshold } != nil
    }
    private func hasTouchXComponent(underThreshold threshold: CGFloat, in touches: Set<UITouch>) -> Bool {
        return touches.first { $0.location(in: self).x < threshold } != nil
    }
}

// MARK: - <GameUIDelegate>
extension GameScene: GameUIDelegate {
    func onDodgeTapped(_ state: Bool, direction: GameUI.DodgeDirection) { /* Unimplemented */}

    func onMovement(_ delta: CGPoint) {
        var newYPosition = playerNode.position.y - delta.y
        if newYPosition < playerNode.size.height / 2 {
            newYPosition = playerNode.size.height / 2
        } else if newYPosition > size.height - playerNode.size.height / 2 {
            newYPosition = size.height - playerNode.size.height / 2
        }
        playerNode.position.y = newYPosition
    }

    func onRestartSelected() {
        let gameScene = GameScene(fileNamed: "GameScene")!
        let transition = SKTransition.moveIn(with: .up, duration: 0.5)
        view?.presentScene(gameScene, transition: transition)
    }

    func onExitSelected() {
        let menuScene = MenuScene(fileNamed: "MenuScene")!
        let transition = SKTransition.doorsCloseVertical(withDuration: 0.5)
        view?.presentScene(menuScene, transition: transition)
    }

    func onSettingsSelected() {
        print("Unimplemented!")
    }

    func onContextToggled(at index: Int, selected: Bool) {
        contextRuleSubscriptions[index] = selected
        // TODO: (TL) fake this
    }
}

// MARK: - <SKPhysicsContactDelegate>
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        (contact.bodyA.node as? Collidable)?.didBeginCollision(with: contact.bodyB.node)
        (contact.bodyB.node as? Collidable)?.didBeginCollision(with: contact.bodyA.node)
    }

    func didEnd(_ contact: SKPhysicsContact) {
        (contact.bodyA.node as? Collidable)?.didEndCollision(with: contact.bodyB.node)
        (contact.bodyB.node as? Collidable)?.didEndCollision(with: contact.bodyA.node)
    }
}
