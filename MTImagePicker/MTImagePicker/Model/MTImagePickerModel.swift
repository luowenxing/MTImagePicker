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
    public var mediaType:MTImagePickerMediaType
    public var sortNumber = 0
    
    init(mediaType:MTImagePickerMediaType,sortNumber:Int) {
        self.mediaType = mediaType
        self.sortNumber = sortNumber
    }
    
    func getFileName() -> String? {
        fatalError("getFileName has not been implemented")
    }
    
    func getThumbImage(size:CGSize)-> UIImage? {
        fatalError("getThumbImage has not been implemented")
    }
    
    func getPreviewImage() -> UIImage?{
        fatalError("getPreviewImage has not been implemented")
    }
    
    func getImageAsync(complete:(UIImage?) -> Void) {
        fatalError("getImageAsync has not been implemented")
    }
    
    func getVideoDurationAsync(complete:(Double) -> Void) {
        fatalError("getVideoDurationAsync has not been implemented")
    }
    
    func getAVPlayerItem () -> AVPlayerItem? {
        fatalError("getAVPlayerItem has not been implemented")
    }
    
    func getFileSize() -> Int {
        fatalError("getFileSize has not been implemented")
    }
}


class MTImagePickerAlbumModel:NSObject {
    
    func getAlbumName() -> String? {
        fatalError("getAlbumName has not been implemented")
    }
    
    func getAlbumImage(size:CGSize) -> UIImage? {
        fatalError("getAlbumImage has not been implemented")
    }
    
    func getAlbumCount() -> Int {
        fatalError("getAlbumCount has not been implemented")
    }
    
    func getMTImagePickerModelsListAsync(complete:[MTImagePickerModel] -> Void) {
        fatalError("getMTImagePickerModelsAsync has not been implemented")
    }
    
}
