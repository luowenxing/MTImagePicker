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
    fileprivate var model:MTImagePickerModel!
    
    
    override func awakeFromNib() {
        scrollview.zoomScale = 1
        scrollview.minimumZoomScale = 1
        scrollview.maximumZoomScale = 3
        scrollview.contentSize = CGSize.zero
        scrollview.delegate = self
        
        imageView.isUserInteractionEnabled = true
        self.scrollview.addSubview(imageView)
        scrollview.delegate = self
        
        // 支持单击全屏，双击放大
        let singTapGesture = UITapGestureRecognizer(target: self, action: #selector(ImagePickerPreviewCell.onImageSingleTap(_:)))
        singTapGesture.numberOfTapsRequired = 1
        singTapGesture.numberOfTouchesRequired = 1
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(ImagePickerPreviewCell.onImageDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.numberOfTouchesRequired = 1
        singTapGesture.require(toFail: doubleTapGesture)
        
        self.addGestureRecognizer(singTapGesture)
        self.addGestureRecognizer(doubleTapGesture)
    }
    
    override func prepareForReuse() {
        scrollview.zoomScale = 1.0
        scrollview.contentSize = CGSize.zero
        imageView.image = nil
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        scrollview.zoomScale = 1.0
        scrollview.contentSize = CGSize.zero
        if let _image = imageView.image {
            let bounds = UIScreen.main.compatibleBounds
            let boundsDept = bounds.width / bounds.height
            let imgDept = _image.size.width / _image.size.height
            // 图片长宽和屏幕的宽高进行比较 设定基准边
            if imgDept > boundsDept {
                imageView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.width / imgDept)
            } else {
                imageView.frame = CGRect(x: 0, y: 0, width: bounds.height * imgDept, height: bounds.height)
            }
            self.scrollview.layoutIfNeeded()
            self.scrollview.frame.origin = CGPoint.zero
            imageView.center = scrollview.center
        }
        
    }
    
    
    func initWithModel(_ model:MTImagePickerModel,controller:MTImagePickerPreviewController) {
        self.model = model
        self.controller = controller
        self.imageView.image = model.getPreviewImage()
        self.layoutSubviews()
    }
    
    @objc func onImageSingleTap(_ sender:UITapGestureRecognizer) {
        if let controller = self.controller {
            controller.topViews.forEach { $0.isHidden = !$0.isHidden }
            controller.bottomViews.forEach { $0.isHidden = !$0.isHidden }
        }
    }
    
    func didEndScroll() {
        self.model.getImageAsync(){
            image in
            self.imageView.image = image
        }
    }
    
    @objc func onImageDoubleTap(_ sender:UITapGestureRecognizer) {
        let zoomScale = scrollview.zoomScale
        if zoomScale <= 1.0 {
            let loc = sender.location(in: sender.view) as CGPoint
            let wh:CGFloat = 1
            let x:CGFloat = loc.x - 0.5
            let y:CGFloat = loc.y - 0.5
            let rect = CGRect(x: x, y: y, width: wh, height: wh)
            scrollview.zoom(to: rect, animated: true)
        } else {
            scrollview.setZoomScale(1.0, animated: true)
        }
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        var xcenter = scrollView.center.x
        var ycenter = scrollView.center.y
        
        xcenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2 : xcenter
        
        ycenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2 : ycenter
        imageView.center = CGPoint(x: xcenter, y: ycenter)
    }
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
