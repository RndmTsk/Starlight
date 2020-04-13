//
//  CollectibleGenerator.swift
//  Starlight
//
//  Created by Terry Latanville on 2019-05-17.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import SpriteKit
import SpriteKitUtils

typealias CollectibleNode = ParallaxGameObject

enum CollectibleType: Int {
    case coin
}

class CollectibleNodeGenerator: NodeGenerator {
    init(templates: [CollectibleType : ParallaxTemplate], screenSize: CGSize) {
        let templateTuples = templates.map { ($0.key.rawValue, $0.value as NodeGenerator.Template) }
        let baseTemplates = Dictionary(templateTuples) { lhs, _ in lhs }
        super.init(atlasName: "Collectibles", templates: baseTemplates, screenSize: screenSize)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions
    override func generateElement(ofType elementType: Int, withTemplate template: NodeGenerator.Template) -> SKNode? {
        guard let collectible = CollectibleType(rawValue: elementType),
            let parallaxTemplate = template as? ParallaxTemplate
            else { return nil }
        return generate(collectible, withTemplate: parallaxTemplate)
    }

    func generate(_ collectible: CollectibleType, withTemplate template: ParallaxTemplate) -> CollectibleNode? {
        switch collectible {
        case .coin:
            return CollectibleNode(atlas: atlas, template: template, screenSize: screenSize)
        }
    }
}
