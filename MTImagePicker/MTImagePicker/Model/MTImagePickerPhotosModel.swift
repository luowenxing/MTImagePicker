//
//  MTImagePickerPhotosModel.swift
//  MTImagePicker
//
//  Created by Luo on 6/27/16.
//  Copyright © 2016 Luo. All rights reserved.
//
import UIKit
import Photos

@available(iOS 8.0, *)
public class MTImagePickerPhotosModel : MTImagePickerModel {
    
    public var phasset:PHAsset!
    init(mediaType: MTImagePickerMediaType, sortNumber: Int,phasset:PHAsset) {
        super.init(mediaType: mediaType, sortNumber: sortNumber)
        self.phasset = phasset
    }
    
    override func getFileName() -> String? {
        var fileName:String?
        self.fetchDataSync(){
            (data,dataUTI,orientation,infoDict) in
            if let name = (infoDict?["PHImageFileURLKey"] as? NSURL)?.lastPathComponent {
                fileName = name
            }
        }
        return fileName
    }
    
    override func getThumbImage()-> UIImage? {
        var img:UIImage?
        let options = PHImageRequestOptions()
        options.deliveryMode = .FastFormat
        options.synchronous = true
        let size = CGSize(width: 75, height: 75)
        PHImageManager.defaultManager().requestImageForAsset(self.phasset, targetSize: size, contentMode: .AspectFill, options: options) {
            image,infoDict in
            img = image
            
        }
        return img
    }
    
    override func getPreviewImage() -> UIImage?{
        var img:UIImage?
        let options = PHImageRequestOptions()
        options.deliveryMode = .FastFormat
        options.synchronous = true
        var size = UIScreen.mainScreen().compatibleBounds.size
        size = CGSize(width: size.width / 3.0 , height: size.height / 3.0)
        PHImageManager.defaultManager().requestImageForAsset(self.phasset, targetSize: size, contentMode: .AspectFit, options: options) {
            image,infoDict in
            img = image
            
        }
        return img
    }
    
    override func getImageAsync(complete:(UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .HighQualityFormat
        let size = UIScreen.mainScreen().compatibleBounds.size
        PHImageManager.defaultManager().requestImageForAsset(self.phasset, targetSize: size, contentMode: .AspectFit, options: options) {
            image,infoDict in
            complete(image)
        }
    }
    
    override func getVideoDurationAsync(complete:(Double) -> Void) {
        PHImageManager.defaultManager().requestAVAssetForVideo(self.phasset, options: nil){
            avasset,_,_ in
            if let asset = avasset{
                let duration = Double(asset.duration.value) / Double(asset.duration.timescale)
                complete(duration)
            }
        }
    }
    
    override func getAVPlayerItem() -> AVPlayerItem? {
        return self.fetchAVPlayerItemSync()
    }
    
    override func getFileSize() -> Int {
        var fileSize = 0
        self.fetchDataSync(){
            (data,dataUTI,orientation,infoDict) in
            if let d = data {
                fileSize = d.length
            }
        }
        return fileSize
    }
    
    private func fetchAVPlayerItemSync() -> AVPlayerItem? {
        var playerItem:AVPlayerItem?
        let sem = dispatch_semaphore_create(0)
        PHImageManager.defaultManager().requestPlayerItemForVideo(self.phasset, options: nil){
            item,infoDict in
            playerItem = item
            dispatch_semaphore_signal(sem)
        }
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER)
        return playerItem
    }
    
    private func fetchDataSync(complete:(NSData?, String?, UIImageOrientation, [NSObject : AnyObject]?) -> Void) {
        let requestOptions = PHImageRequestOptions()
        requestOptions.synchronous = true
        PHImageManager.defaultManager().requestImageDataForAsset(self.phasset, options: requestOptions){
            (data,dataUTI,orientation,infoDict) in
            complete(data, dataUTI, orientation, infoDict)
        }
    }
    
    
}

@available(iOS 8.0, *)
class MTImagePickerPhotosAlbumModel:MTImagePickerAlbumModel {
    
    private var collection:PHAssetCollection
    private var mediaTypes:[MTImagePickerMediaType]
    
    init(collection:PHAssetCollection,mediaTypes:[MTImagePickerMediaType]) {
        self.collection = collection
        self.mediaTypes = mediaTypes
    }
    
    override func getAlbumCount() -> Int {
        return self.collection.estimatedAssetCount
    }
    
    override func getAlbumName() -> String? {
        return self.collection.localizedTitle
    }
    
    override func getAlbumImage() -> UIImage? {
        let result = PHAsset.fetchAssetsInAssetCollection(self.collection, options: nil)
        if let asset = result.objectAtIndex(0) as? PHAsset {
            let scale = UIScreen.mainScreen().scale
            let size = CGSizeMake( 50 * scale, 50 * scale)
            var image:UIImage?
            PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: size, contentMode: .AspectFit, options: nil) {
                img,infoDict in
                image = img
                
            }
            return image
        }
        return nil
    }
    
    override func getMTImagePickerModelsListAsync(complete: [MTImagePickerModel] -> Void) {
//        let result = PHAsset.fetchAssetsInAssetCollection(self.collection, options: nil
    }
}




