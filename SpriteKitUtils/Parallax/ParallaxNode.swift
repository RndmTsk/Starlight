//
//  ParallaxNode.swift
//  SpriteKitUtils
//
//  Created by Terry Latanville on 2019-05-17.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import SpriteKit
import ResourceKit

public class ParallaxNode: SKNode {
    // MARK: - Lifecycle Functions
    public init(nodeConfigs: [ParallaxNodeConfig], size: CGSize) {
        super.init()
        nodeConfigs
            .map { (nodeConfig: $0, atlas: ResourceManager.shared.atlas(named: $0.atlasName)) }
            .map { (nodeConfig: $0.nodeConfig, textures: ResourceManager.shared.textures(from: $0.atlas, named: $0.nodeConfig.assetGroup)) }
            .map { ParallaxLayerNode(textures: $0.textures, size: size, parallaxConfig: $0.nodeConfig) }
            .forEach { addChild($0) }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions
    func switchAtlas(to atlasName: String) {
        let nextAtlas = ResourceManager.shared.atlas(named: atlasName)
        for case let parallaxChild as ParallaxLayerNode in children {
            parallaxChild.nextAtlas = nextAtlas
        }
    }
}

// MARK: - <Updatable>
extension ParallaxNode: Updatable {
    public func update(deltaTime: CFTimeInterval, multiplier: CGFloat) {
        for case let updatableChild as Updatable in children {
            updatableChild.update(deltaTime: deltaTime, multiplier: multiplier)
        }
    }
}
