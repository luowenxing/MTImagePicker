//
//  ImagePickerPreviewCell.swift
//  MTImagePicker
//
//  Created by Luo on 5/24/16.
//  Copyright © 2016 Luo. All rights reserved.
//

import UIKit

class ImagePickerPreviewCell:UICollectionViewCell,UIScrollViewDelegate {
    
    @IBOutlet weak var scrollview: UIScrollView!
    var imageView: UIImageView! = UIImageView()
    
    weak var controller:MTImagePickerPreviewController?
    private var model:MTImagePickerModel!
    
    
    override func awakeFromNib() {
        scrollview.zoomScale = 1
        scrollview.minimumZoomScale = 1
        scrollview.maximumZoomScale = 3
        scrollview.contentSize = CGSizeZero
        scrollview.delegate = self
        
        imageView.userInteractionEnabled = true
        self.scrollview.addSubview(imageView)
        scrollview.delegate = self
        
        // 支持单击全屏，双击放大
        let singTapGesture = UITapGestureRecognizer(target: self, action: #selector(ImagePickerPreviewCell.onImageSingleTap(_:)))
        singTapGesture.numberOfTapsRequired = 1
        singTapGesture.numberOfTouchesRequired = 1
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(ImagePickerPreviewCell.onImageDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.numberOfTouchesRequired = 1
        singTapGesture.requireGestureRecognizerToFail(doubleTapGesture)
        
        imageView.addGestureRecognizer(singTapGesture)
        imageView.addGestureRecognizer(doubleTapGesture)
    }
    
    override func prepareForReuse() {
        scrollview.zoomScale = 1.0
        scrollview.contentSize = CGSizeZero
        imageView.image = nil
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        scrollview.zoomScale = 1.0
        scrollview.contentSize = CGSizeZero
        if let _image = imageView.image {
            let bounds = UIScreen.mainScreen().compatibleBounds
            let boundsDept = bounds.width / bounds.height
            let imgDept = _image.size.width / _image.size.height
            // 图片长宽和屏幕的宽高进行比较 设定基准边
            if imgDept > boundsDept {
                imageView.frame = CGRectMake(0, 0, bounds.width, bounds.width / imgDept)
            } else {
                imageView.frame = CGRectMake(0, 0, bounds.height * imgDept, bounds.height)
            }
            self.scrollview.layoutIfNeeded()
            imageView.center = scrollview.center
        }
        
    }
    
    
    func initWithModel(model:MTImagePickerModel,controller:MTImagePickerPreviewController) {
        self.model = model
        self.controller = controller
        self.imageView.image = model.getPreviewImage()
        self.layoutSubviews()
    }
    
    func onImageSingleTap(sender:UITapGestureRecognizer) {
        if let controller = self.controller {
            controller.topView.hidden = !controller.topView.hidden
            controller.bottomView.hidden = !controller.bottomView.hidden
        }
    }
    
    func didEndScroll() {
        self.model.getImageAsync(){
            image in
            self.imageView.image = image
        }
    }
    
    func onImageDoubleTap(sender:UITapGestureRecognizer) {
        let zoomScale = scrollview.zoomScale
        if zoomScale <= 1.0 {
            let loc = sender.locationInView(sender.view) as CGPoint
            let wh:CGFloat = 1
            let x:CGFloat = loc.x - 0.5
            let y:CGFloat = loc.y - 0.5
            let rect = CGRectMake(x, y, wh, wh)
            scrollview.zoomToRect(rect, animated: true)
        } else {
            scrollview.setZoomScale(1.0, animated: true)
        }
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        var xcenter = scrollView.center.x
        var ycenter = scrollView.center.y
        
        xcenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2 : xcenter
        
        ycenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2 : ycenter
        imageView.center = CGPointMake(xcenter, ycenter)
    }
    
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}