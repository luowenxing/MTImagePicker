//
//  ImageSelectorViewModel.swift
//  CMBMobile
//
//  Created by Luo on 5/9/16.
//  Copyright © 2016 Yst－WHB. All rights reserved.
//

import UIKit
import AssetsLibrary
import Photos

class MTImagePickerAssetsModel:MTImagePickerModel {
    
    var asset:ALAsset!
    var lib:ALAssetsLibrary!
    private lazy var rept:ALAssetRepresentation = {
       return self.asset.defaultRepresentation()
    }()
    
    init(mediaType:MTImagePickerMediaType,sortNumber:Int,source:MTImagePickerSource, asset:ALAsset,lib:ALAssetsLibrary) {
        super.init(mediaType: mediaType, sortNumber: sortNumber,source:source)
        self.asset = asset
        self.lib = lib
    }
    override func getFileName() -> String? {
        return self.rept.filename()
    }
    
    override func getThumbImage()-> UIImage? {
        return UIImage(CGImage: self.asset.thumbnail().takeUnretainedValue())
    }
    
    override func getPreviewImage() -> UIImage?{
        return UIImage(CGImage: self.asset.aspectRatioThumbnail().takeUnretainedValue())
    }
    
    override func getImageAsync(complete:(UIImage?) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
            let image = UIImage(CGImage: self.rept.fullScreenImage().takeUnretainedValue())
            dispatch_async(dispatch_get_main_queue()){
                complete(image)
            }
        }
    }
    
    override func getVideoDuration() -> Double {
        return self.asset.valueForProperty(ALAssetPropertyDuration).doubleValue
    }
    
    override func getUrl() ->NSURL {
        return self.rept.url()
    }
    
    override func getFileSize() -> Int {
        return Int(self.rept.size())
    }

}


@available(iOS 8.0, *)
class MTImagePickerPhotosModel:MTImagePickerModel {
    
    var phasset:PHAsset!
    init(mediaType: MTImagePickerMediaType, sortNumber: Int, source: MTImagePickerSource,phasset:PHAsset) {
        super.init(mediaType: mediaType, sortNumber: sortNumber, source: source)
        self.phasset = phasset
    }
    
    override func getFileName() -> String? {
        return nil
    }
    
    override func getThumbImage()-> UIImage? {
        return nil
    }
    
    override func getPreviewImage() -> UIImage?{
        return nil
    }
    
    override func getImageAsync(complete:(UIImage?) -> Void) {
        
    }
    
    override func getVideoDuration() -> Double {
        return 0
    }
    
    override func getUrl() ->NSURL {
        return NSURL()
    }
    
    override func getFileSize() -> Int {
        return 0
    }

    
    
}

class MTImagePickerModel:NSObject {
    var mediaType:MTImagePickerMediaType
    var source:MTImagePickerSource
    var sortNumber = 0
    
    init(mediaType:MTImagePickerMediaType,sortNumber:Int,source:MTImagePickerSource) {
        self.mediaType = mediaType
        self.sortNumber = sortNumber
        self.source = source
    }
    
    func getFileName() -> String? {
        return nil
    }
    
    func getThumbImage()-> UIImage? {
        return nil
    }
    
    func getPreviewImage() -> UIImage?{
        return nil
    }
    
    func getImageAsync(complete:(UIImage?) -> Void) {
        
    }
    
    func getVideoDuration() -> Double {
        return 0
    }
    
    func getUrl() ->NSURL {
        return NSURL()
    }
    
    func getFileSize() -> Int {
        return 0
    }
}
