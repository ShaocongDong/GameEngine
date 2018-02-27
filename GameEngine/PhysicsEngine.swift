//
//  PhysicsEngine.swift
//  GameEngine
//
//  Created by DongShaocong on 13/2/18.
//  Copyright © 2018 nus.cs3217.a0148008. All rights reserved.
//

import Foundation
import UIKit

/**
 Physics Engine for updating object positions
 */
public class PhysicsEngine {

    /// update the moving objects positions,
    /// because the object are irrelevant in the game, the position will just get updated
    /// - Parameters:
    ///     - movingObject: the moving object to be updated
    ///     - renderer: the Game renderer
    static func updateMovingObjects(movingObject: GameObject, renderer: GameRenderer) {
        movingObject.velocityX += movingObject.acceleraX * displayFrameTimeIntervalDuration
        movingObject.velocityY += movingObject.acceleraY * displayFrameTimeIntervalDuration
        movingObject.positionX += movingObject.velocityX * displayFrameTimeIntervalDuration
        movingObject.positionY += movingObject.velocityY * displayFrameTimeIntervalDuration
    }

    /// update the shoot object positions
    /// - important:
    ///     - collisions between shoot bubbles
    ///     - collisions between device edges
    ///     - collisions with the resting bubble and snapping to grid of the shoot bubble
    ///     - erasion of the bubbles and the removal of disconnected bubbles
    /// - Parameters:
    ///     - shootObject: the shoot object to be updated
    ///     - motherView: the UI view in the game area
    ///     - renderer: the Game renderer
    static func updateShootObject(shootObject: ShootGameObject, motherView: UIView, renderer: GameRenderer) {

        let bubbleRadius = motherView.layer.bounds.width / CGFloat(numberOfBubblesLongRow * 2)
        var currentPosition = CGPoint(x: shootObject.positionX, y: shootObject.positionY)

        //determine updated acceleration with magnetic bubbles (find closest magnetic)
        let megneticForce: CGFloat = 500
        currentPosition = CGPoint(x: shootObject.positionX, y: shootObject.positionY)
        for object in renderer.restingObjects where object.color == .magnetic {
            let otherPosition = CGPoint(x: object.positionX, y: object.positionY)
            //let currentDistance = GameUtil.distance(currentPosition, otherPosition)
            let deltaX = currentPosition.x - otherPosition.x
            let deltaY = currentPosition.y - otherPosition.y
            shootObject.acceleraX += megneticForce / abs(deltaX * deltaX) * deltaX
            shootObject.acceleraY += megneticForce / abs(deltaY * deltaY) * deltaY
        }

        //detect collisions determine collision with the moving bubbles
        for object in renderer.shootingObjects {
            if object === shootObject {
                continue
            }
            let otherPosition = CGPoint(x: object.positionX, y: object.positionY)
            if GameUtil.distance(currentPosition, otherPosition) <= 2 * bubbleRadius {
                PhysicsProcessor.processVelocity(shootObject, other: object, renderer: renderer, motherView: motherView)
                continue
            }
        }

        //determine collision with the resting bubble on top
        for object in renderer.restingObjects {
            if let shootObject = object as? ShootGameObject {
                if shootObject.shootFlag == true {
                    continue
                }
            }
            let otherPosition = CGPoint(x: object.positionX, y: object.positionY)
            if GameUtil.distance(currentPosition, otherPosition) <= 2 * bubbleRadius {
                //make the object snap to the grid
                snapToTheGridOperation(shootObject, other: object,
                                       renderer: renderer, motherView: motherView)
                //deal with special bubbles effects
                SpecialBubbleEngine.specialBubbleProcess(renderer: renderer,
                                                         motherView: motherView,
                                                         shootObject: shootObject)

                detectDisconnectedDroppingOperation(renderer: renderer, motherView: motherView)

                print(shootObject.color.rawValue)
                break
            }
        }

        //position updates by newton's linear motion formula
        shootObject.velocityX += shootObject.acceleraX * displayFrameTimeIntervalDuration
        shootObject.velocityY += shootObject.acceleraY * displayFrameTimeIntervalDuration
        shootObject.positionX += shootObject.velocityX * displayFrameTimeIntervalDuration
        shootObject.positionY += shootObject.velocityY * displayFrameTimeIntervalDuration

        shootObject.acceleraY = 0
        shootObject.acceleraX = 0
        //detect and process collision with the left and right side of the device
        if shootObject.positionX - bubbleRadius <= 0 {
            shootObject.positionX = bubbleRadius
            shootObject.velocityX *= -1.0
        } else if shootObject.positionX + bubbleRadius >= motherView.layer.bounds.width {
            shootObject.positionX = motherView.layer.bounds.width - bubbleRadius
            shootObject.velocityX *= -1.0
        }

        //detect collision with the upper wall of the device
        if shootObject.positionY - bubbleRadius <= 0 {
            snapToGridCellCollidingWithUpperWall(shootObject, renderer: renderer, motherView: motherView)
        }
    }

    /// detect the cells to be erased with more than 2 colors connected together
    private static func detectCellsToBeErasedOperation(shootObject: ShootGameObject, renderer: GameRenderer,
                                                       motherView: UIView, currentPosition: CGPoint) {
        guard let collectionView = motherView.viewWithTag(bubbleCollectionViewTagNumber)
            as? BubbleCollectionView else {
                fatalError("The collection view cannot be found!")
        }
        var position = CGPoint(x: currentPosition.x, y: currentPosition.y)
        let bubbleRadius = motherView.layer.bounds.width / CGFloat(numberOfBubblesLongRow * 2)
        let verticalOffset = bubbleRadius * CGFloat(3.0.squareRoot())
        let maximumDeadLineHeight = verticalOffset * 11.0 + bubbleRadius * 2.0
        if position.y > maximumDeadLineHeight {
            return
        }
        while collectionView.indexPathForItem(at: position)?.row == nil {
            var increment: CGFloat = smallIncrementAdjustment
            position.x += increment //default to the right hand side
            if position.x > motherView.layer.bounds.width {
                increment *= smallIncrementAdjustmentFactor
            }
        }
        guard let startingIndex = collectionView.indexPathForItem(at: position)?.row else {
            fatalError("The bubble position cannot be converted into index path")
        }

        let eraseColor = shootObject.color
        let adjacencySet = renderer.indexPathAdjacencySet
        let restingGraphDict = renderer.restingObjectsDictionary
        traverseEraseAdjacentCells(startingIndex: startingIndex, eraseColor: eraseColor,
                                   adjacencySet: adjacencySet, restingGraphDict: restingGraphDict,
                                   renderer: renderer)
        //detect disconneceted dropping cells after some cells have been erased
        detectDisconnectedDroppingOperation(renderer: renderer, motherView: motherView)
    }

    /// traverse to find the cells to be erase
    private static func traverseEraseAdjacentCells(startingIndex: Int, eraseColor: GameObjectType,
                                                   adjacencySet: [Int: Set<Int>], restingGraphDict: [Int: GameObject],
                                                   renderer: GameRenderer) {
        var cellsIndexToBeErased = Set<Int>()
        //use BFS to traverse all the adjacent nodes
        var indexQueue = [Int]()
        var visitedIndices = Set<Int>()
        indexQueue.append(startingIndex)
        while !indexQueue.isEmpty {
            let currentIndex = indexQueue.remove(at: 0)
            if visitedIndices.contains(currentIndex) {
                continue
            }
            visitedIndices.insert(currentIndex)
            guard let currentObject = restingGraphDict[currentIndex] else {
                continue
            }
            if currentObject.color.rawValue == eraseColor.rawValue {
                cellsIndexToBeErased.insert(currentIndex)
                guard let adjacentIndices = adjacencySet[currentIndex] else {
                    continue
                }
                for index in adjacentIndices {
                    indexQueue.append(index)
                }
            }
        }
        //skip if the cells to be erased is smaller than 3
        if cellsIndexToBeErased.count < 3 {
            return
        }
        PhysicsProcessor.processObjectToBeFading(cellsIndexToBeErased: cellsIndexToBeErased, renderer: renderer)
    }

    /// detect and drop the cells that are disconnected
    private static func detectDisconnectedDroppingOperation(renderer: GameRenderer, motherView: UIView) {
        let adjacencySet = renderer.indexPathAdjacencySet
        let restingGraphDict = renderer.restingObjectsDictionary
        var indicesQueue = [Int]()
        var visitedIndices = Set<Int>()
        for i in 0..<12 {
            guard restingGraphDict[i] != nil else {
                continue
            }
            indicesQueue.append(i)
        }
        while !indicesQueue.isEmpty {
            let index = indicesQueue.remove(at: 0)
            if visitedIndices.contains(index) {
                continue
            }
            visitedIndices.insert(index)
            guard restingGraphDict[index] != nil else {
                continue
            }
            guard let adjacentIndices = adjacencySet[index] else {
                continue
            }
            for adjacentIndex in adjacentIndices {
                indicesQueue.append(adjacentIndex)
            }
        }
        let allKeySet = Set(restingGraphDict.keys)
        let droppingIndices = allKeySet.subtracting(visitedIndices)
        var cellsToDrop = [GameObject]()
        for i in droppingIndices {
            guard let gameObjectAtIndex = restingGraphDict[i] else {
                continue
            }
            cellsToDrop.append(gameObjectAtIndex)
        }
        let bubbleRadius = motherView.layer.bounds.width / CGFloat(numberOfBubblesLongRow * 2)
        PhysicsProcessor.processObjectToBeMoving(cellsToDrop: cellsToDrop, renderer: renderer,
                                                 droppingIndices: droppingIndices, bubbleRadius: bubbleRadius)
    }

    /// help the bubble snap to a grid when colliding with other bubbles
    private static func snapToTheGridOperation(_ objectA: ShootGameObject,
                                               other objectB: GameObject, renderer: GameRenderer,
                                               motherView: UIView) {
        // primitive calculation
        let bubbleRadius = motherView.layer.bounds.width / CGFloat(numberOfBubblesLongRow * 2)
        let verticalOffset = bubbleRadius * CGFloat(3.0.squareRoot())
        let maximumDeadLineHeight = verticalOffset *
            CGFloat(numberOfBubblesShortRow) + bubbleRadius * 2.0
        let currentPosition = CGPoint(x: objectA.positionX, y: objectA.positionY)
        let otherPositionX = objectB.positionX
        let otherPositionY = objectB.positionY

        var pointList = [CGPoint]()
        if otherPositionX - bubbleRadius * 2.0 > 0 {
            pointList.append(CGPoint(x: otherPositionX - bubbleRadius * 2.0, y: otherPositionY))
        }
        if otherPositionX + bubbleRadius * 2.0 < motherView.layer.bounds.width {
            pointList.append(CGPoint(x: otherPositionX + bubbleRadius * 2.0, y: otherPositionY))
        }
        if otherPositionX - bubbleRadius * 2.0 >= 0 {
            if otherPositionY - verticalOffset > 0 {
                pointList.append(CGPoint(x: otherPositionX - bubbleRadius,
                                         y: otherPositionY - verticalOffset))
            }
            pointList.append(CGPoint(x: otherPositionX - bubbleRadius,
                                     y: otherPositionY + verticalOffset))
        }
        if otherPositionX + bubbleRadius * 2.0 <= motherView.layer.bounds.width {
            if otherPositionY - verticalOffset > 0 {
                pointList.append(CGPoint(x: otherPositionX + bubbleRadius,
                                         y: otherPositionY - verticalOffset))
            }
            pointList.append(CGPoint(x: otherPositionX + bubbleRadius,
                                     y: otherPositionY + verticalOffset))
        }
        var indexOfClosestPoint = 0
        for i in 0..<pointList.count {
            if GameUtil.distance(currentPosition, pointList[i]) <
                GameUtil.distance(currentPosition, pointList[indexOfClosestPoint]) {
                indexOfClosestPoint = i
            }
        }
        objectA.positionX = pointList[indexOfClosestPoint].x
        objectA.positionY = pointList[indexOfClosestPoint].y

        //primitive checking for non-attachable low position bubbles
        if objectA.positionY > maximumDeadLineHeight {
            objectA.shootFlag = false
            return
        }

        objectA.velocityX = 0
        objectA.velocityY = 0
        objectA.shootFlag = false
        PhysicsProcessor.processObjectToBeResting(objectA: objectA, renderer: renderer, motherView: motherView)
        //detect adjacent connected cells
        detectCellsToBeErasedOperation(shootObject: objectA,
                                       renderer: renderer, motherView: motherView,
                                       currentPosition: CGPoint(x: objectA.positionX, y: objectA.positionY))
    }

    /// help the bubble snap to a grid when colliding with the upper wall
    private static func snapToGridCellCollidingWithUpperWall(_ objectA: ShootGameObject, renderer: GameRenderer,
                                                             motherView: UIView) {
        guard let collectionView = motherView.viewWithTag(bubbleCollectionViewTagNumber)
            as? BubbleCollectionView else {
                fatalError("The collection view is not found or its tag is wrong!")
        }
        let currentPosition = CGPoint(x: objectA.positionX, y: objectA.positionY)
        var increment: CGFloat = smallIncrementAdjustment
        while collectionView.indexPathForItem(at: currentPosition) == nil {
            objectA.positionX += increment //default to the right hand side
            if objectA.positionX > motherView.layer.bounds.width {
                increment *= smallIncrementAdjustmentFactor
            }
        }
        guard let indexPath = collectionView.indexPathForItem(at: currentPosition) else {
            return
        }
        guard let cell = collectionView.cellForItem(at: indexPath) as? CustomBubbleViewCell else {
            fatalError("The indexpath doesn't exist a custom bubble view cell!")
        }
        let correctPosition = cell.layer.position
        objectA.positionX = correctPosition.x
        objectA.positionY = correctPosition.y
        objectA.velocityX = 0
        objectA.velocityY = 0
        objectA.shootFlag = false
        PhysicsProcessor.processObjectToBeResting(objectA: objectA, renderer: renderer, motherView: motherView)
        detectCellsToBeErasedOperation(shootObject: objectA,
                                       renderer: renderer, motherView: motherView,
                                       currentPosition: currentPosition)
    }

}
