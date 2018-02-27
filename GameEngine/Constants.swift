//
//  Constants.swift
//  GameEngine
//
//  Created by DongShaocong on 19/2/18.
//  Copyright © 2018 nus.cs3217.a0148008. All rights reserved.
//

import Foundation
import UIKit

// numbers, duration, and tags
let numberOfBubbles = 138
let numberOfBubbleTypes = 9
let numberOfColorBubbleTypes = 4
let numberOfCroppedImageInBurstBubble = 4
let numberOfRandomGeneratedBubble = numberOfBubbles / 2
let numberOfBubblesLongRow = 12
let numberOfBubblesShortRow = 11
let numberOfBubblesForOneSection = 23
let maximumTagNumber = 1_000
let notUsedTagNumber = -1
let bubbleCollectionViewTagNumber = 1_001
let cannonTagNumber = 1_002
let cannonBaseTagNumber = 1_003
let gestureDisableTimeDuration = 0.3
let displayPreferredFramesPerSecond = 60
let smallIncrementAdjustment: CGFloat = 0.5
let smallIncrementAdjustmentFactor: CGFloat = -1.1
let cannonProcessImageLength: CGFloat = 800
let cannonProcessImageHeight: CGFloat = 533.5
let cannonProcessNumberOfRows = 2
let cannonProcessNumberOfColumns = 6
let cannonResizeScaleFactor: CGFloat = 0.4
let cannonHeightAdjustingFactor: CGFloat = 0.84
let cannonBaseResizeScaleFactor: CGFloat = 0.73
let verticalAnchorOffsetForCannon: CGFloat = 0.8

// velocity and acceleration settings
let shootBubbleUpwardVelocity: CGFloat = 35
let erasedBubbleDownwardAcceleration: CGFloat = 30
/// computed property to randonly give the bubble dropping intial velocity
var bubbleDroppingRandomVelocity: CGFloat {
    let velocityList: [CGFloat] = [-5, -10, -20, -30, -40, 0, 5, 10, 20, 30, 40]
    let randomNumber = arc4random_uniform(UInt32(velocityList.count))
    return velocityList[Int(randomNumber)] * 0.1
}

// alpha value and display settings
let fadingAlphaDecrementAmount: CGFloat = 0.08
let displayFrameTimeIntervalDuration: CGFloat = CGFloat(1.0 / Double(displayPreferredFramesPerSecond))
let bubbleQueueFrontAlphaValue: CGFloat = 1
let bubbleQueueMiddleAlphaValue: CGFloat = 0.75
let bubbleQueueEndAlphaValue: CGFloat = 0.5
let queueWaitingHeightRatio: CGFloat = 0.85
let movingObjectAlpha: CGFloat = 0.3

let cannonBaseImage = UIImage(named: "cannon-base")
/// computed property for accessing the colored bubble array
var imageRollingDictionary: [GameObjectType: UIImage] {
    var dict = [GameObjectType: UIImage]()
    guard let redBallImage = UIImage(named: "bubble-red"),
        let blueBallImage = UIImage(named: "bubble-blue"),
        let greenBallImage = UIImage(named: "bubble-green"),
        let orangeBallImage = UIImage(named: "bubble-orange"),
        let lightningBallImage = UIImage(named: "bubble-lightning"),
        let indestructibleBallImage = UIImage(named: "bubble-indestructible"),
        let starBallImage = UIImage(named: "bubble-star"),
        let magneticBallImage = UIImage(named: "bubble-magnetic"),
        let bombBallImage = UIImage(named: "bubble-bomb") else {
            fatalError("The image assets are not complete!")
    }
    dict[.red] = redBallImage
    dict[.blue] = blueBallImage
    dict[.green] = greenBallImage
    dict[.orange] = orangeBallImage
    dict[.lightning] = lightningBallImage
    dict[.indestructible] = indestructibleBallImage
    dict[.star] = starBallImage
    dict[.magnetic] = magneticBallImage
    dict[.bomb] = bombBallImage
    return dict
}

var colorBubbleRollingDictionary: [GameObjectType: UIImage] {
    var dict = [GameObjectType: UIImage]()
    guard let redBallImage = UIImage(named: "bubble-red"),
        let blueBallImage = UIImage(named: "bubble-blue"),
        let greenBallImage = UIImage(named: "bubble-green"),
        let orangeBallImage = UIImage(named: "bubble-orange") else {
            fatalError("The image assets are not complete!")
    }
    dict[.red] = redBallImage
    dict[.blue] = blueBallImage
    dict[.green] = greenBallImage
    dict[.orange] = orangeBallImage
    return dict
}

var bombingCroppedImageDict: [Int: UIImage] {
    var dict = [Int: UIImage]()
    guard let fullBombingImageProcess = UIImage(named: "bubble-burst") else {
        fatalError("Cannot find bombing animation sprite!")
    }
    let imageSquareSize = fullBombingImageProcess.size.height
    for x in 0..<numberOfCroppedImageInBurstBubble {
        guard let image = fullBombingImageProcess.cgImage?.cropping(to:
            CGRect(x: CGFloat(x) * imageSquareSize, y: 0, width: imageSquareSize, height: imageSquareSize)) else {
                fatalError("Cannot find bombing animationn sprite part!")
        }
        dict[x + 1] = UIImage(cgImage: image)
    }
    return dict
}

var cannonCroppedImageDict: [Int: UIImage] {
    var dict = [Int: UIImage]()
    guard let cannonFiringImageProcess = UIImage(named: "cannon") else {
        fatalError("Cannon find cannon firing animation sprite!")
    }
    let width = cannonFiringImageProcess.size.width / CGFloat(cannonProcessNumberOfColumns)
    let height = cannonFiringImageProcess.size.height / CGFloat(cannonProcessNumberOfRows)
    for y in 0..<cannonProcessNumberOfRows {
        for x in 0..<cannonProcessNumberOfColumns {
            guard let image = cannonFiringImageProcess.cgImage?.cropping(to:
                CGRect(x: CGFloat(x) * width * 2,
                       y: CGFloat(y) * height * 2, width: width * 2,
                       height: cannonFiringImageProcess.size.height)) else {
                    fatalError("Cannot find bombing animation sprite part!")
            }
            dict[y * cannonProcessNumberOfColumns + x + 1] = UIImage(cgImage: image)
        }
    }
    return dict
}
