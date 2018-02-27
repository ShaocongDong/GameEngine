//
//  CustomBubbleCollectionViewLayout.swift
//  LevelDesigner
//
//  Created by DongShaocong on 3/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

public class CustomBubbleCollectionViewLayout: UICollectionViewLayout {
    private(set) var numberOfColumns = 1

    // Two kinds of lines, therefore we need 12+11 kinds of xOffsets
    let longLineBubbleNumber = 12
    let shortLineBubbleNumber = 11

    // for every rows, we have different yOffsets
    let rowBubbleNumber = 12

    //Attributes cache to boost up efficiency
    private var cache = [UICollectionViewLayoutAttributes]()

    //Computed property for getting the collection view width info
    private var width: CGFloat {
        if let currentCollectionView = collectionView {
            return currentCollectionView.bounds.width
        }
        return 0
    }

    //Computed property for getting the collection view width info
    private var height: CGFloat {
        if let currentCollectionView = collectionView {
            return currentCollectionView.bounds.height
        }
        return 0
    }

    override func prepare() {
        if cache.isEmpty {
            let squareWidth = CGFloat( width / 12.0 )
            // manual calculation for offsets
            let commonFactor = 3.0
            let commonOffset = squareWidth * CGFloat( commonFactor.squareRoot() / 2.0 )

            // two arrays to calculate the item sizes
            var xOffsets: [CGFloat] = []
            var yOffsets: [CGFloat] = []

            //setting up vertical offsets
            yOffsets.append(0)
            for i in 1..<rowBubbleNumber {
                yOffsets.append(yOffsets[i - 1] + commonOffset)
            }

            //setting up horizontal offsets
            xOffsets.append(0)
            for i in 1..<longLineBubbleNumber {
                xOffsets.append(xOffsets[i - 1] + squareWidth)
            }

            xOffsets.append(squareWidth / 2.0)
            for i in 1..<shortLineBubbleNumber {
                xOffsets.append(xOffsets[longLineBubbleNumber + i - 1] + squareWidth)
            }

            //setting up UI collection view attributes and direct to cache
            guard let currentCollectionView = collectionView else {
                return
            }
            for i in 0..<currentCollectionView.numberOfItems(inSection: 0) {
                let moduloFactor = longLineBubbleNumber + shortLineBubbleNumber
                let indexPath = NSIndexPath(item: i, section: 0)
                let rowNumber = indexPath.row

                // index calculation for cell placement
                var yIndex = rowNumber / moduloFactor * 2
                let xIndex = rowNumber % moduloFactor
                if xIndex < longLineBubbleNumber {
                    yIndex += 0
                } else {
                    yIndex += 1
                }

                let frame = CGRect(x: xOffsets[xIndex], y: yOffsets[yIndex],
                                   width: squareWidth - 2, height: squareWidth - 2)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath as IndexPath)
                attributes.frame = frame
                cache.append(attributes)
            }
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache
    }

}
