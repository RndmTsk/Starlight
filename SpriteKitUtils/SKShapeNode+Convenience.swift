//
//  SKShapeNode+Convenience.swift
//  SpriteKitUtils
//
//  Created by Terry Latanville on 2019-05-17.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import SpriteKit

public extension SKShapeNode {
    class func circle(withRadius radius: CGFloat, strokeColor: SKColor = .clear, fillColor: SKColor = .clear) -> SKShapeNode {
        let circle = SKShapeNode()
        let rect = CGRect(x: -radius / 2, y: -radius / 2, width: radius, height: radius)
        circle.path = CGPath(roundedRect: rect, cornerWidth: rect.size.width / 2, cornerHeight: rect.size.height / 2, transform: nil)
        circle.strokeColor = strokeColor
        circle.fillColor = fillColor

        return circle
    }

    class func rectangle(withExtents extents: CGRect, strokeColor: SKColor = .clear, fillColor: SKColor = .clear) -> SKShapeNode {
        let rectangle = SKShapeNode()
        rectangle.path = CGPath(rect: extents, transform: nil)
        rectangle.strokeColor = strokeColor
        rectangle.fillColor = fillColor

        return rectangle
    }
}
