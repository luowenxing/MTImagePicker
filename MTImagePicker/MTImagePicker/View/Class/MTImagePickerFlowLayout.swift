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
        // - 1 避免精度丢失导致一行放不下4个
        let width = ( bounds.width - self.space - 1 ) / itemOfRow
        self.itemSize = CGSize(width: width, height: width)
        if let collectionView = (self.collectionView as? MTImagePickerCollectionView) {
            collectionView.leading.constant = self.space / 2.0
            collectionView.trailing.constant = self.space / 2.0
        }
    }
    
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint) -> CGPoint {
        if let indexPath = (self.collectionView as? MTImagePickerCollectionView)?.prevIndexPath {
            return CGPoint(x: 0, y: self.itemSize.width * CGFloat( indexPath.row / 4 ))
        }
        return super.targetContentOffsetForProposedContentOffset(proposedContentOffset)
    }
}


class MTImagePickerPreviewFlowLayout:UICollectionViewFlowLayout {
    override func prepareLayout() {
        self.minimumLineSpacing = 0
        self.minimumInteritemSpacing = 0
    }
    
    //旋转后保证还是之前的图片
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint) -> CGPoint {
        if let collectionView = self.collectionView {
            let page = round(proposedContentOffset.x / ( collectionView.bounds.size.height + 20 ))
            return CGPointMake(page * ( collectionView.bounds.size.width ), 0)
        }
        return CGPointZero
    }
    
}