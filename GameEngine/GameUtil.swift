//
//  GameUtil.swift
//  GameEngine
//
//  Created by DongShaocong on 13/2/18.
//  Copyright © 2018 nus.cs3217.a0148008. All rights reserved.
//

import Foundation
import UIKit

/**
`GameUtil` is a utility class for holding helper functions
 */
class GameUtil {

    /// wrapper function for the actual next bubble to shoot algorithm
    static func nextBubbleToShoot() -> UIImage {
        let randomNumber = Int(arc4random_uniform(UInt32(numberOfColorBubbleTypes)))
        let objectType = Array(colorBubbleRollingDictionary.keys)[randomNumber]
        guard let image = colorBubbleRollingDictionary[objectType] else {
            fatalError("Error encountered when trying to get image")
        }
        return image
    }

    static func nextBubbleToInitialise() -> UIImage {
        let randomNumber = Int(arc4random_uniform(UInt32(numberOfBubbleTypes)))
        let objectType = Array(imageRollingDictionary.keys)[randomNumber]
        guard let image = imageRollingDictionary[objectType] else {
            fatalError("Error encountered when trying to get image")
        }
        return image
    }

    /// calculate and return the indexPath adjacency list for the collection view
    static func calculateIndexPathRowAdjacencySet() -> [Int: Set<Int>] {
        var dict = [Int: Set<Int>]()
        // process first line elements
        dict[0] = [1, 12]
        dict[11] = [10, 22]
        for i in 1..<11 {
            dict[i] = [i - 1, i + 1, i + 11, i + 12]
        }
        //process last line elements
        dict[127] = [115, 116, 128]
        dict[137] = [125, 126, 136]
        for i in 128..<137 {
            dict[i] = [i - 1, i + 1, i - 11, i - 12]
        }
        //process middle lines elements
        for i in 12..<127 {
            if (i - 12) % 23 == 0 { //process short line first element
                dict[i] = [i - 12, i - 11, i + 1, i + 11, i + 12]
            } else if i % 23 == 0 { //process long line first element
                dict[i] = [i - 11, i + 1, i + 12]
            } else if (i - 22) % 23 == 0 { //process short line last element
                dict[i] = [i - 12, i - 11, i - 1, i + 11, i + 12]
            } else if (i - 11) % 23 == 0 { //process long line last element
                dict[i] = [i - 12, i - 1, i + 11]
            } else { //process inner cells
                dict[i] = [i - 12, i - 11, i - 1, i + 1, i + 11, i + 12]
            }
        }
        return dict
    }

    /// find distance between two CGPoint
    static func distance(_ pointA: CGPoint, _ pointB: CGPoint) -> CGFloat {
        let xDist = pointA.x - pointB.x
        let yDist = pointA.y - pointB.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }

}
