//
//  GameRenderer.swift
//  GameEngine
//
//  Created by DongShaocong on 13/2/18.
//  Copyright © 2018 nus.cs3217.a0148008. All rights reserved.
//

import Foundation
import UIKit

/**
`GameRenderer` is the UI renderer acompanying the physics engine
 + It uses display link for syncing and animating bubbles
 + Some of object collections are accessed from physics engines for modification and updates.
 */
public class GameRenderer {

    private var motherView: UIView
    private var shootBubble: UIImageView
    var gameModel: GameModel?
    var shootingObjects = Set<GameObject>()
    var movingObjects = Set<GameObject>()
    var restingObjects = [GameObject]()
    var fadingObjects = Set<GameObject>()
    var bombingObjects = Set<GameObject>()
    var bombingObjectDictionary = [Int: Set<GameObject>]()
    var indexPathAdjacencySet: [Int: Set<Int>]
    var restingObjectsDictionary = [Int: GameObject]()

    var movingTags: Set<Int> {
        var resultList = Set<Int>()
        for shootingObject in shootingObjects {
            resultList.insert(shootingObject.tag)
        }
        for movingObject in movingObjects {
            resultList.insert(movingObject.tag)
        }
        return resultList
    }

    public init(motherView: UIView, shootBubble: UIImageView, indexPathAdjacencySet: [Int: Set<Int>]) {
        self.motherView = motherView
        self.shootBubble = shootBubble
        self.indexPathAdjacencySet = indexPathAdjacencySet
        bombingObjectDictionary[0] = Set<GameObject>()
        bombingObjectDictionary[1] = Set<GameObject>()
        bombingObjectDictionary[2] = Set<GameObject>()
        bombingObjectDictionary[3] = Set<GameObject>()
        bombingObjectDictionary[4] = Set<GameObject>()
    }

    func feedGameModel(gameModel: GameModel) {
        self.gameModel = gameModel
    }

    /// create the display link to sync and animate bubbles
    func createDisplayLink() {
        let displaylink = CADisplayLink(target: self,
                                        selector: #selector(step))
        displaylink.preferredFramesPerSecond = displayPreferredFramesPerSecond

        displaylink.add(to: .current, forMode: .defaultRunLoopMode)
    }

    /// step function for updaging object positions and states
    @objc
    func step(displaylink: CADisplayLink) {
        updateBombingObjects()
        updateFadingObjects()
        updateMovingObjects()
        updateShootingObjects()
    }

    func updateBombingObjects() {
        guard let bombingObjectSet4 = bombingObjectDictionary[4] else {
            fatalError("The bombing object sets in dictionary are not initialised properly!")
        }
        for object in bombingObjectSet4 {
            let objectView = motherView.viewWithTag(object.tag)
            objectView?.alpha = 0
        }
        bombingObjectDictionary[0] = bombingObjects
        bombingObjects = Set<GameObject>()
        for index in [3, 2, 1, 0] {
            guard let bombingObjectSet = bombingObjectDictionary[index] else {
                fatalError("The bombing object sets in dictionary are not initialised properly!")
            }
            for object in bombingObjectSet {
                let objectView = motherView.viewWithTag(object.tag)
                if objectView is CustomBubbleViewCell {
                    guard let objectViewCell = objectView as? CustomBubbleViewCell else {
                        fatalError("The object view cannot be converted into Custom BubbleViewCell!")
                    }
                    objectViewCell.setCellImage(image: bombingCroppedImageDict[index + 1])
                } else {
                    guard let objectViewCell = objectView as? UIImageView else {
                        fatalError("The object view cannot be converted into UIImageView!")
                    }
                    objectViewCell.image = bombingCroppedImageDict[index + 1]
                }
            }
            bombingObjectDictionary[index + 1] = bombingObjectDictionary[index]
        }
    }

    func updateFadingObjects() {
        for object in fadingObjects {
            guard let objectView = motherView.viewWithTag(object.tag) else {
                fatalError("The MotherView doesn't contain this tagged bubble!")
            }
            objectView.alpha -= fadingAlphaDecrementAmount
            if objectView.alpha <= 0 { //fading Complete
                fadingObjects = fadingObjects.filter { !($0 === object) }
            }

        }
    }

    /// update the shooting objects positions
    /// index is used for updating and deleting the bubble
    /// below the deadlines temporarily
    func updateShootingObjects() {
        for object in shootingObjects {
            guard let shootObject = object as? ShootGameObject else {
                return
            }
            let shootObjectTag = shootObject.tag
            PhysicsEngine.updateShootObject(shootObject: shootObject, motherView: motherView, renderer: self)

            guard let objectView = motherView.viewWithTag(shootObjectTag) else {
                fatalError("The motherView doesn't contain this tagged bubble!")
            }
            objectView.center = CGPoint(x: shootObject.positionX, y: shootObject.positionY)
            let bubbleRadius = motherView.layer.bounds.width / 24.0
            let verticalOffset = bubbleRadius * CGFloat(3.0.squareRoot())
            let maximumDeadLineHeight = verticalOffset * 11.0 + bubbleRadius * 2.0
            if !shootObject.shootFlag && shootObject.positionY > maximumDeadLineHeight {
                fadingObjects.insert(shootObject)
                shootingObjects.remove(shootObject)
            }
        }
    }

    /// update moving objects and possibly replace a CustomBubbleCollectionViewCell
    /// with a UIImageView for it to move around, this is for compatability
    /// between level designer and the gameplay
    func updateMovingObjects() {
        for object in movingObjects {
            PhysicsEngine.updateMovingObjects(movingObject: object, renderer: self)
            guard let objectView = motherView.viewWithTag(object.tag) else {
                fatalError("The motherView doesn't contain this tagged bubble!")
            }
            if objectView is CustomBubbleViewCell {
                guard let colletionView = motherView.viewWithTag(bubbleCollectionViewTagNumber)
                    as? BubbleCollectionView else {
                        fatalError("The motherView doesn't contain the collection view!")
                }
                guard let indexPath = colletionView.indexPathForItem(at:
                    CGPoint(x: object.positionX, y: object.positionY)) else {
                        fatalError("The cell is misplaced in collection view!")
                }
                guard let cell = colletionView.cellForItem(at: indexPath) as? CustomBubbleViewCell else {
                    fatalError("The cell type is incorrect!")
                }
                let cellSize = colletionView.layer.bounds.width / 12
                let objectView = UIImageView(frame:
                    CGRect(x: object.positionX, y: object.positionY, width: cellSize, height: cellSize))
                objectView.image = cell.getCellImage().image
                objectView.tag = cell.tag
                objectView.alpha = movingObjectAlpha
                motherView.addSubview(objectView)
                cell.tag = notUsedTagNumber
                cell.setCellImage(image: nil)
            } else {
                objectView.alpha = movingObjectAlpha
                objectView.center = CGPoint(x: object.positionX, y: object.positionY)
            }
        }
    }

}
