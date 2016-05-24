//
//  MTImagePickerFlowLayout.swift
//  MTImagePicker
//
//  Created by Luo on 5/24/16.
//  Copyright © 2016 Luo. All rights reserved.
//

import UIKit

class MTImagePickerFlowLayout:UICollectionViewFlowLayout {
    var space:CGFloat!
    override func prepareLayout() {
        self.minimumLineSpacing = 0
        self.minimumInteritemSpacing = 0
        let bounds = UIScreen.mainScreen().compatibleBounds
        let itemOfRow:CGFloat = 4
        self.space = bounds.width  / itemOfRow / 20.0
        let width = ( bounds.width - self.space) / itemOfRow
        self.itemSize = CGSize(width: width, height: width)
    }
}


class MTImagePickerPreviewFlowLayout:UICollectionViewFlowLayout {
    override func prepareLayout() {
        self.minimumLineSpacing = 0
        self.minimumInteritemSpacing = 0
    }
}