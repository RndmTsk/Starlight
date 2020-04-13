//
//  SKAction+Convenience.swift
//  SpriteKitUtils
//
//  Created by Terry Latanville on 2019-05-17.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import SpriteKit

public extension SKAction {
    static var bobSequence: SKAction = {
        let bobUpActionEaseOut = SKAction.moveBy(x: 0, y: 5, duration: 1)
        bobUpActionEaseOut.timingMode = .easeOut
        let bobUpActionEaseIn  = SKAction.moveBy(x: 0, y: 5, duration: 1)
        bobUpActionEaseIn.timingMode = .easeIn
        let bobDownActionEaseOut = SKAction.moveBy(x: 0, y: -5, duration: 1)
        bobDownActionEaseOut.timingMode = .easeOut
        let bobDownActionEaseIn = SKAction.moveBy(x: 0, y: -5, duration: 1)
        bobDownActionEaseIn.timingMode = .easeIn

        return SKAction.sequence([bobUpActionEaseOut, bobDownActionEaseIn, bobDownActionEaseOut, bobUpActionEaseIn])
    }()

    static var spinSequence: SKAction = {
        let spinStep1 = SKAction.scaleX(by: 0.1, y: 0, duration: 1)
        // TODO: (TL) ...
        return SKAction.sequence([spinStep1])
    }()
}
