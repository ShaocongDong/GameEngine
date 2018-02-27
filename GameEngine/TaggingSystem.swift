//
//  TaggingSystem.swift
//  GameEngine
//
//  Created by DongShaocong on 13/2/18.
//  Copyright © 2018 nus.cs3217.a0148008. All rights reserved.
//

import Foundation
import UIKit

/**
 TaggingSystem is a system to generate tag number
 and help keep all the tag numbers unique
 */
class TaggingSystem {
    private static var taggingDict = [Int: Bool]()
    private static var initialStateFlag = true

    static func initialiseStates() {
        for i in 0..<maximumTagNumber {
            taggingDict[i] = false //false is the idle state
        }
    }

    static func getTagNumber() -> Int {
        if initialStateFlag {
            self.initialiseStates()
            self.initialStateFlag = false
        }
        for i in 1..<maximumTagNumber where taggingDict[i] == false {
            taggingDict[i] = true
            return i
        }
        return -1
    }

    static func releaseTagNumber(with tagNumber: Int) {
        taggingDict[tagNumber] = false
    }
}
