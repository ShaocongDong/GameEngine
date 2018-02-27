//
//  BubbleCollectionView.swift
//  GameEngine
//
//  Created by DongShaocong on 10/2/18.
//  Copyright © 2018 nus.cs3217.a0148008. All rights reserved.
//

import UIKit

public class BubbleCollectionView: UICollectionView {

    // For drawing a red line to indicate the dead line where bubble cannot exceed
    override func draw(_ rect: CGRect) {
        // Drawing code
        let aPath = UIBezierPath()
        let viewWidth = self.bounds.width
        let diameter = viewWidth / 12
        let commonOffset = diameter * CGFloat( 3.squareRoot() / 2.0 )
        let height = diameter + commonOffset * 11
        aPath.move(to: CGPoint(x: 0, y: height))
        aPath.addLine(to: CGPoint(x: viewWidth, y: height))
        aPath.close()
        UIColor.cyan.set()
        aPath.lineWidth = 5.0
        aPath.stroke(with: .normal, alpha: 0.25)
    }

}
