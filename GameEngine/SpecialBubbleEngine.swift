//
//  SpecialBubbleEngine.swift
//  GameEngine
//
//  Created by DongShaocong on 25/2/18.
//  Copyright © 2018 nus.cs3217.a0148008. All rights reserved.
//

import Foundation
import UIKit

public class SpecialBubbleEngine {

    static func specialBubbleProcess(renderer: GameRenderer, motherView: UIView,
                                     shootObject: ShootGameObject) {
        guard let collectionView = motherView.viewWithTag(bubbleCollectionViewTagNumber) as?
            BubbleCollectionView else {
                fatalError("The collection view is not found in mother view!")
        }
        guard let indexPath = collectionView.indexPathForItem(at:
            CGPoint(x: shootObject.positionX, y: shootObject.positionY)) else {
                fatalError("The shoot object is not found in a valid cell position!")
        }
        var adjacentBubbles = [GameObject]()
        guard let adjacentIndices = renderer.indexPathAdjacencySet[indexPath.row] else {
            fatalError("The cell position has no valid adjacent cell indices")
        }
        for index in adjacentIndices {
            guard let bubble = renderer.restingObjectsDictionary[index] else {
                continue
            }
            adjacentBubbles.append(bubble)
        }
        var lightningBombFlag = false

        //detect collisions with lightning bubble
        for object in adjacentBubbles where object.color == .lightning {
            removeSameRowBubbles(renderer: renderer,
                                 lightningBubbleObject: object,
                                 motherView: motherView)
            lightningBombFlag = true
            renderer.bombingObjects.insert(shootObject)
            break
        }

        //detect collisions with bomb bubble
        for object in adjacentBubbles where object.color == .bomb {
            removeAdjacentBubbles(renderer: renderer,
                                  bombBubbleObject: object,
                                  motherView: motherView)
            lightningBombFlag = true
            renderer.bombingObjects.insert(shootObject)
            break
        }

        //processing for chain effects and bombing effects
        if lightningBombFlag {
            processBombingObjectsRemoval(renderer: renderer, motherView: motherView)
        }

        //detect collisions with star bubble
        for object in adjacentBubbles where object.color == .star {
            removeSameColorBubbles(renderer: renderer,
                                   starBubbleObject: object,
                                   motherView: motherView, color: shootObject.color)
        }
    }

    private static func processBombingObjectsRemoval(renderer: GameRenderer, motherView: UIView) {
        //remove from resting objects
        renderer.restingObjects = renderer.restingObjects.filter { !renderer.bombingObjects.contains($0) }
        //remove from resting object dictionary
        for object in renderer.bombingObjects {
            guard let collectionView = motherView.viewWithTag(bubbleCollectionViewTagNumber) as?
                BubbleCollectionView else {
                    fatalError("The collection view is not found in mother view!")
            }
            guard let indexPath = collectionView.indexPathForItem(at:
                CGPoint(x: object.positionX, y: object.positionY)) else {
                    fatalError("The object cannot be found in a valid cell position!")
            }
            renderer.restingObjectsDictionary.removeValue(forKey: indexPath.row)
        }
    }

    private static func removeSameRowBubbles(renderer: GameRenderer,
                                             lightningBubbleObject: GameObject,
                                             motherView: UIView) {
        let bubbleRadius = motherView.layer.bounds.width / CGFloat(numberOfBubblesLongRow * 2)
        let height = lightningBubbleObject.positionY
        var objectsList = [GameObject]()
        for i in 0..<renderer.restingObjects.count {
            let currentObject = renderer.restingObjects[i]
            if abs(currentObject.positionY - height) < bubbleRadius {
                objectsList.append(currentObject)
            }
        }
        //trigger chaining effects
        renderer.bombingObjects.insert(lightningBubbleObject)
        for object in objectsList {
            if renderer.bombingObjects.contains(object) {
                continue
            }
            removeObject(renderer: renderer, object: object, motherView: motherView)
        }
    }

    private static func removeAdjacentBubbles(renderer: GameRenderer,
                                              bombBubbleObject: GameObject,
                                              motherView: UIView) {
        guard let collectionView = motherView.viewWithTag(bubbleCollectionViewTagNumber) as?
            BubbleCollectionView else {
                fatalError("The collection view is not found in mother view!")
        }
        guard let indexPath = collectionView.indexPathForItem(at:
            CGPoint(x: bombBubbleObject.positionX, y: bombBubbleObject.positionY)) else {
                fatalError("The object cannot be found in a valid cell position!")
        }
        guard let adjacentIndexPathRows = renderer.indexPathAdjacencySet[indexPath.row] else {
            fatalError("The object cannot be found in resting dictionary!")
        }
        var objectsList = [GameObject]()
        for i in 0..<renderer.restingObjects.count {
            let currentObject = renderer.restingObjects[i]
            if let currentShootGameObject = currentObject as? ShootGameObject {
                if currentShootGameObject.shootFlag == true {
                    continue
                }
            }
            let positionX = currentObject.positionX
            let positionY = currentObject.positionY
            guard let indexPath = collectionView.indexPathForItem(at:
                CGPoint(x: positionX, y: positionY)) else {
                    fatalError("The indexPath for resting bubble is not found!")
            }
            if adjacentIndexPathRows.contains(indexPath.row) {
                objectsList.append(currentObject)
            }
        }
        renderer.bombingObjects.insert(bombBubbleObject)
        //trigger chaining effects
        for object in objectsList {
            if renderer.bombingObjects.contains(object) {
                continue
            }
            removeObject(renderer: renderer, object: object, motherView: motherView)
        }

    }

    private static func removeObject(renderer: GameRenderer, object: GameObject, motherView: UIView) {
        if object.color == .lightning {
            removeSameRowBubbles(renderer: renderer, lightningBubbleObject: object, motherView: motherView)
        } else if object.color == .bomb {
            removeAdjacentBubbles(renderer: renderer, bombBubbleObject: object, motherView: motherView)
        } else {
            renderer.bombingObjects.insert(object)
        }
    }

    private static func removeSameColorBubbles(renderer: GameRenderer,
                                               starBubbleObject: GameObject,
                                               motherView: UIView, color: GameObjectType) {

        guard let collectionView = motherView.viewWithTag(bubbleCollectionViewTagNumber) as?
            BubbleCollectionView else {
                fatalError("The collection view is not found in mother view!")
        }
        guard let indexPath = collectionView.indexPathForItem(at:
            CGPoint(x: starBubbleObject.positionX, y: starBubbleObject.positionY)) else {
                fatalError("The object cannot be found in a valid cell position!")
        }
        renderer.fadingObjects.insert(starBubbleObject)
        renderer.restingObjectsDictionary.removeValue(forKey: indexPath.row)
        renderer.restingObjects = renderer.restingObjects.filter { $0.tag != starBubbleObject.tag }
        var restingIndices = [Int]()
        for i in 0..<renderer.restingObjects.count {
            let currentObject = renderer.restingObjects[i]
            if let currentShootGameObject = currentObject as? ShootGameObject {
                if currentShootGameObject.shootFlag == true {
                    continue
                }
            }
            if currentObject.color == color {
                renderer.fadingObjects.insert(currentObject)
                guard let indexPath = collectionView.indexPathForItem(at:
                    CGPoint(x: currentObject.positionX, y: currentObject.positionY)) else {
                        fatalError("The object cannot be found in a valid cell position!")
                }
                renderer.restingObjectsDictionary.removeValue(forKey: indexPath.row)
                restingIndices.append(i)
            }
        }
        for index in restingIndices.sorted().reversed() {
            renderer.restingObjects.remove(at: index)
        }
    }
}
