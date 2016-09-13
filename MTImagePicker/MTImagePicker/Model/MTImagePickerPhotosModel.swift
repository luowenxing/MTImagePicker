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
    
    override func getThumbImage(size:CGSize)-> UIImage? {
        var img:UIImage?
        let options = PHImageRequestOptions()
        options.deliveryMode = .FastFormat
        options.synchronous = true
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
    
    private var result:PHFetchResult
    private var _albumCount:Int
    private var _albumName:String?
    
    init(result:PHFetchResult,albumCount:Int,albumName:String?) {
        self.result = result
        self._albumName = albumName
        self._albumCount = albumCount
    }
    
    override func getAlbumCount() -> Int {
        return self._albumCount
    }
    
    override func getAlbumName() -> String? {
        return self._albumName
    }
    
    override func getAlbumImage(size:CGSize) -> UIImage? {
        if let asset = self.result.objectAtIndex(0) as? PHAsset {
            let model = MTImagePickerPhotosModel(mediaType: .Photo, sortNumber: 0, phasset: asset)
            return model.getThumbImage(size)
        }
        return nil
    }
    
    override func getMTImagePickerModelsListAsync(complete: [MTImagePickerModel] -> Void) {
        var models = [MTImagePickerModel]()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
            self.result.enumerateObjectsUsingBlock({ (asset, index, isStop) -> Void in
                if let phasset = asset as? PHAsset {
                    let mediaType:MTImagePickerMediaType = phasset.mediaType == .Image ? .Photo : .Video
                    let model = MTImagePickerPhotosModel(mediaType: mediaType, sortNumber: index, phasset: phasset)
                    models.append(model)
                }
            })
            dispatch_async(dispatch_get_main_queue()) {
                complete(models)
            }
        }
    }
}




