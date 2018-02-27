//
//  GameModel.swift
//  GameEngine
//
//  Created by DongShaocong on 13/2/18.
//  Copyright © 2018 nus.cs3217.a0148008. All rights reserved.
//

import Foundation
import UIKit

/**
GameModel, the ViewModel accompanying the game, it takes care of
 + intialisation of the game
 + handle the bubble queue and cannon bubble at the lower end of the device
 */
public class GameModel {
    private var gameEnd: Bool
    private var gameRenderer: GameRenderer
    private var motherView: UIView
    private var indexPathAdjacencySet: [Int: Set<Int>]

    init(motherView: UIView, shootBubble: UIImageView, bubbleCollectionView: BubbleCollectionView) {
        gameEnd = false
        self.motherView = motherView
        indexPathAdjacencySet = GameUtil.calculateIndexPathRowAdjacencySet()
        gameRenderer = GameRenderer(motherView: motherView, shootBubble:
            shootBubble, indexPathAdjacencySet: indexPathAdjacencySet)
        initialiseObjectsCreation(bubbleCollectionView: bubbleCollectionView, shootBubble: shootBubble)
    }

    private func initialiseObjectsCreation(bubbleCollectionView: BubbleCollectionView, shootBubble: UIImageView) {
        gameRenderer.feedGameModel(gameModel: self)
        takeBubbleForNextShoot(shootBubble: shootBubble)
        //initialise the rest of the current level resting bubble
        for i in 0..<numberOfBubbles {
            let indexPath = IndexPath(item: i, section: 0)
            guard let cell = bubbleCollectionView.cellForItem(at: indexPath) as? CustomBubbleViewCell else {
                continue
            }
            guard let cellImage = cell.getCellImage().image else {
                continue
            }
            let cellX = cell.layer.position.x
            let cellY = cell.layer.position.y
            let bubbleGameObject = GameObject(fromX: cellX, fromY: cellY, atX: 0.0,
                                          atY: 0.0, withX: 0.0, withY: 0.0,
                                          tag: cell.tag,
                                          color: getColorPropertyFromCellImage(image: cellImage))
            gameRenderer.restingObjects.append(bubbleGameObject)
            gameRenderer.restingObjectsDictionary[indexPath.row] = bubbleGameObject
        }
    }

    func handleGameShootBubble(ratioXToY: CGFloat) {
        print("handle the bubble shooting")
        var index = -1
        for i in 0..<gameRenderer.restingObjects.count {
            guard let object = gameRenderer.restingObjects[i] as? ShootGameObject else {
                continue
            }
            if object.shootFlag == false {
                continue
            }
            index = i
        }
        if index != -1 {
            let bubbleRadius = motherView.layer.bounds.width / CGFloat(numberOfBubblesLongRow * 2)
            let object = gameRenderer.restingObjects[index]
            let angle = atan(ratioXToY)
            var vX = shootBubbleUpwardVelocity * sin(angle) * bubbleRadius
            var vY = shootBubbleUpwardVelocity * cos(angle) * bubbleRadius
            // The bubble should go upward
            if vY > 0 {
                vY *= -1.0
                vX *= -1.0
            }
            object.velocityX = vX
            object.velocityY = vY
            gameRenderer.shootingObjects.insert(object)
            gameRenderer.restingObjects.remove(at: index)
        }
    }

    func takeBubbleForNextShoot(shootBubble: UIImageView) {
        //get initial shootbubble center coordinates
        let x = shootBubble.layer.position.x
        let y = shootBubble.layer.position.y
        //add to resting objects list
        guard let cellImage = shootBubble.image else {
            return
        }
        gameRenderer.restingObjects.append(ShootGameObject(shootFlag: true, fromX: x, fromY: y, atX: 0.0,
                                                           atY: 0.0, withX: 0.0, withY: 0.0, tag: shootBubble.tag,
                                                           color: getColorPropertyFromCellImage(image: cellImage)))
    }

    private func getColorPropertyFromCellImage(image: UIImage) -> GameObjectType {
        for (type, bubbleImage) in imageRollingDictionary where bubbleImage == image {
                return type
        }
        fatalError("The image type is not found in image rolling dictionary")
    }

    func startGameLoop() {
        print("Start Gaming!")
        gameRenderer.createDisplayLink()
    }

}
