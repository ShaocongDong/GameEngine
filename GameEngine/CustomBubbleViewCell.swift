//
//  CustomBubbleViewCell.swift
//  LevelDesigner
//
//  Created by DongShaocong on 31/1/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

public class CustomBubbleViewCell: UICollectionViewCell {

    @IBOutlet private var cellImage: UIImageView!

    func setCellImage(image: UIImage?) {
        cellImage.image = image
    }

    func getCellImage() -> UIImageView {
        return cellImage
    }

}
