//
//  ImageSelectorViewModel.swift
//  CMBMobile
//
//  Created by Luo on 5/9/16.
//  Copyright © 2016 Yst－WHB. All rights reserved.
//

import UIKit
import AssetsLibrary

class MTImagePickerModel:NSObject {
    
    var mediaType:MTImagePickerMediaType
    var sortNumber = 0
    var asset:ALAsset
    var lib:ALAssetsLibrary
    
    init(mediaType:MTImagePickerMediaType,sortNumber:Int,asset:ALAsset,lib:ALAssetsLibrary) {
        self.mediaType = mediaType
        self.sortNumber = sortNumber
        self.asset = asset
        self.lib = lib
    }
    
    func getThumbImage()-> UIImage? {
        return UIImage(CGImage: self.asset.thumbnail().takeUnretainedValue())
    }
    
    func getPreviewImage() -> UIImage?{
        return UIImage(CGImage: self.asset.aspectRatioThumbnail().takeUnretainedValue())
    }
    
    func getImageAsync(complete:(UIImage?) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
            let rept = self.asset.defaultRepresentation()
            let image = UIImage(CGImage: rept.fullScreenImage().takeUnretainedValue())
            dispatch_async(dispatch_get_main_queue()){
                complete(image)
            }
        }
    }
    
    func getVideoDuration() -> String {
        let duration = self.asset.valueForProperty(ALAssetPropertyDuration).doubleValue
        let ticks = Int(duration)
        let text = String(format: "%d:%02d",ticks/60,ticks%60)
        return text
    }
    
    func getUrl() ->NSURL {
        return self.asset.defaultRepresentation().url()
    }
    
}
