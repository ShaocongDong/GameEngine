//
//  ShootGameObject.swift
//  GameEngine
//
//  Created by DongShaocong on 13/2/18.
//  Copyright © 2018 nus.cs3217.a0148008. All rights reserved.
//

import Foundation
import UIKit

/// ShootGameObject, with one more attribute, a shootFlag,
/// designed for the shoot bubbles
class ShootGameObject: GameObject {
    var shootFlag: Bool

    init(shootFlag: Bool, fromX: CGFloat, fromY: CGFloat, atX: CGFloat,
         atY: CGFloat, withX: CGFloat, withY: CGFloat, tag: Int, color: GameObjectType) {
        self.shootFlag = shootFlag
        super.init(fromX: fromX, fromY: fromY, atX: atX, atY: atY,
                   withX: withX, withY: withY, tag: tag, color: color)
    }

}
