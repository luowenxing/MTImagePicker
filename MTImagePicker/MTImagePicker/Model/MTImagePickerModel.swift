//
//  ImageSelectorViewModel.swift
//  CMBMobile
//
//  Created by Luo on 5/9/16.
//  Copyright © 2016 Yst－WHB. All rights reserved.
//

import UIKit
import AVFoundation

public class MTImagePickerModel:NSObject {
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
    
    func getVideoDurationAsync(complete:(Double) -> Void) {
        
    }
    
    func getAVPlayerItem () -> AVPlayerItem? {
        return nil
    }
    
    func getFileSize() -> Int {
        return 0
    }
}
