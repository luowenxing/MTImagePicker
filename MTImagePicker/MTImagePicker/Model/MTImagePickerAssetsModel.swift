//
//  MTImagePickerAssetsModel.swift
//  MTImagePicker
//
//  Created by Luo on 6/27/16.
//  Copyright © 2016 Luo. All rights reserved.
//
import UIKit
import AssetsLibrary
import AVFoundation

public class MTImagePickerAssetsModel : MTImagePickerModel {
    
    public var asset:ALAsset!
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
    
    override func getVideoDurationAsync(complete:(Double) -> Void) {
        complete(self.asset.valueForProperty(ALAssetPropertyDuration).doubleValue)
    }
    
    override func getAVPlayerItem() -> AVPlayerItem? {
        return AVPlayerItem(URL: self.rept.url())
    }
    
    override func getFileSize() -> Int {
        return Int(self.rept.size())
    }
    
}