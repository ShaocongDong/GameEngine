//
//  GameObject.swift
//  GameEngine
//
//  Created by DongShaocong on 13/2/18.
//  Copyright © 2018 nus.cs3217.a0148008. All rights reserved.
//

import Foundation
import UIKit

/**
 GameObject that lives in the physics engine world,
 it facilitates position updates and states update
 of the real bubble in the game
 */
public class GameObject: NSObject {
    var positionX: CGFloat
    var positionY: CGFloat
    var velocityX: CGFloat
    var velocityY: CGFloat
    var acceleraX: CGFloat
    var acceleraY: CGFloat
    var tag: Int
    var color: GameObjectType

    init(fromX: CGFloat, fromY: CGFloat, atX: CGFloat, atY: CGFloat,
         withX: CGFloat, withY: CGFloat, tag: Int, color: GameObjectType) {
        positionX = fromX
        positionY = fromY
        velocityX = atX
        velocityY = atY
        acceleraX = withX
        acceleraY = withY
        self.tag = tag
        self.color = color
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? GameObject else {
            return false
        }
        return self === other
    }
}
