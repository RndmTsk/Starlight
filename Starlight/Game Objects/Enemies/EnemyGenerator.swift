//
//  EnemyGenerator.swift
//  Starlight
//
//  Created by Terry Latanville on 2019-05-17.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import SpriteKit
import SpriteKitUtils

// MARK: - Enemy Types
enum EnemyType: Int {
    case basic
    case charger
}

class EnemyNodeGenerator: NodeGenerator {
    init(templates: [EnemyType: ParallaxTemplate], screenSize: CGSize) {
        let templateTuples = templates.map { ($0.key.rawValue, $0.value as NodeGenerator.Template) }
        let baseTemplates = Dictionary(templateTuples) { lhs, _ in lhs }
        super.init(atlasName: "Enemies", templates: baseTemplates, screenSize: screenSize)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions
    override func generateElement(ofType elementType: Int, withTemplate template: NodeGenerator.Template) -> SKNode? {
        guard let enemy = EnemyType(rawValue: elementType),
            let parallaxTemplate = template as? ParallaxTemplate
            else { return nil }
        return generate(enemy, withTemplate: parallaxTemplate)
    }

    func generate(_ enemy: EnemyType, withTemplate template: ParallaxTemplate) -> EnemyNode? {
        switch enemy {
        case .basic:
            return EnemyNode(atlas: atlas, template: template, screenSize: screenSize)
        case .charger:
            return ChargingEnemyNode(atlas: atlas, template: template, screenSize: screenSize)
        }
    }
}

