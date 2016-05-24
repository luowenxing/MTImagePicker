//
//  MTImageSelectorViewCell.swift
//  MTImagePicker
//
//  Created by Luo on 5/24/16.
//  Copyright © 2016 Luo. All rights reserved.
//

import UIKit

class MTImagePickerCell:UICollectionViewCell {
    
    @IBOutlet weak var videoDuration: UILabel!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var leading: NSLayoutConstraint!
    @IBOutlet weak var trailing: NSLayoutConstraint!
    @IBOutlet weak var top: NSLayoutConstraint!
    
    var indexPath:NSIndexPath!
}