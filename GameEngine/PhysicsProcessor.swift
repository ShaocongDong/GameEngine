//
//  PhysicsProcessor.swift
//  GameEngine
//
//  Created by DongShaocong on 20/2/18.
//  Copyright © 2018 nus.cs3217.a0148008. All rights reserved.
//

import Foundation
import UIKit

/**
`PhysicsProcessor` is a processing class facilitating the PhysicsEngine
 + process the resting process of the bubble
 + process the fading process of the bubble
 + process the moving process of the bubble
 + process the valocity exchange of the colliding bubble
 */
class PhysicsProcessor {

    /// process the resting process of the bubble
    static func processObjectToBeResting(objectA: GameObject, renderer: GameRenderer, motherView: UIView) {
        for object in renderer.shootingObjects
            where object === objectA {
                guard let collectionView = motherView.viewWithTag(bubbleCollectionViewTagNumber)
                    as? BubbleCollectionView else {
                        fatalError("The collection view cannot be retrieved!")
                }
                guard let indexPath = collectionView.indexPathForItem(at:
                    CGPoint(x: objectA.positionX, y: objectA.positionY)) else {
                        objectA.positionX += smallIncrementAdjustment //default to the right hand side
                        if objectA.positionX > motherView.layer.bounds.width {
                            objectA.positionX -= smallIncrementAdjustment * 2.0
                        }
                        return
                }
                renderer.restingObjects.append(objectA)
                renderer.restingObjectsDictionary[indexPath.row] = objectA
                renderer.shootingObjects.remove(objectA)
                break
        }
    }

    /// process the valocity exchange of the colliding bubble
    static func processVelocity(_ objectA: GameObject,
                                other objectB: GameObject, renderer: GameRenderer, motherView: UIView) {
        if objectB.velocityX == 0 && objectB.velocityY == 0 {
            objectA.velocityX = 0
            objectA.velocityY = 0
            processObjectToBeResting(objectA: objectA, renderer: renderer, motherView: motherView)
            return
        }
        let tempAX = objectA.velocityX
        objectA.velocityX = objectB.velocityX
        objectB.velocityX = tempAX
        let tempAY = objectA.velocityY
        objectA.velocityY = objectB.velocityY
        objectB.velocityY = tempAY
    }

    /// process the fading process of the bubble
    static func processObjectToBeFading(cellsIndexToBeErased: Set<Int>, renderer: GameRenderer) {
        //remove the indexed objects
        var cellsToBeErased = [GameObject]()
        for i in cellsIndexToBeErased {
            guard let gameObjectAtIndex = renderer.restingObjectsDictionary[i] else {
                continue
            }
            cellsToBeErased.append(gameObjectAtIndex)
        }
        //remove resting objects records
        renderer.restingObjects = renderer.restingObjects.filter { !cellsToBeErased.contains($0) }
        for index in cellsIndexToBeErased {
            renderer.restingObjectsDictionary.removeValue(forKey: index)
        }
        //add erased cell to fading objects list
        for object in cellsToBeErased {
            renderer.fadingObjects.insert(object)
        }
    }

    /// process the moving process of the bubble
    static func processObjectToBeMoving(cellsToDrop: [GameObject], renderer: GameRenderer,
                                        droppingIndices: Set<Int>, bubbleRadius: CGFloat) {
        //remove resting objects records
        renderer.restingObjects = renderer.restingObjects.filter { !cellsToDrop.contains($0) }
        for index in droppingIndices {
            renderer.restingObjectsDictionary.removeValue(forKey: index)
        }
        //add erased cell to fading objects list
        for object in cellsToDrop {
            object.acceleraY = erasedBubbleDownwardAcceleration * bubbleRadius
            object.velocityX = bubbleDroppingRandomVelocity * bubbleRadius
            object.velocityY = bubbleDroppingRandomVelocity * bubbleRadius
            renderer.movingObjects.insert(object)
        }
    }
}
