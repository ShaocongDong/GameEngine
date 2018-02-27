//
//  GameObjectType.swift
//  GameEngine
//
//  Created by DongShaocong on 20/2/18.
//  Copyright © 2018 nus.cs3217.a0148008. All rights reserved.
//

import Foundation

/// Game Object type enum, with color or special bubble type
public enum GameObjectType: String {
    case red = "RED"
    case blue = "BLUE"
    case green = "GREEN"
    case orange = "ORANGE"
    case bomb = "BOMB"
    case star = "STAR"
    case magnetic = "MAGNETIC"
    case lightning = "LIGHTNING"
    case indestructible = "INDESTRUCTIBLE"
}
