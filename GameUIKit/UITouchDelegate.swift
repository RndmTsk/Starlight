//
//  UIDelegate.swift
//  Starlight
//
//  Created by Terry Latanville on 2019-05-16.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import SpriteKit

public typealias UIElement = SKNode
public typealias UIPanel = SKSpriteNode

public protocol UITouchDelegate {
    func onTouchDown(_ sender: UIElement)
    func onTouchUp(_ sender: UIElement)
    func onTouchCancelled(_ sender: UIElement)
}

public extension UITouchDelegate {
    func onTouchDown(_ sender: UIElement) {}
    func onTouchUp(_ sender: UIElement) {}
    func onTouchCancelled(_ sender: UIElement) {}
}

