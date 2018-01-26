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
    init(mediaType: MTImagePickerMediaType,phasset:PHAsset) {
        super.init(mediaType: mediaType)
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
        options.deliveryMode = .fastFormat
        options.isSynchronous = true
        PHImageManager.default().requestImage(for: self.phasset, targetSize: size, contentMode: .aspectFill, options: options) {
            image,infoDict in
            img = image
            
        }
        return img
    }
    
    override func getPreviewImage() -> UIImage?{
        var img:UIImage?
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.isSynchronous = true
        var size = UIScreen.main.compatibleBounds.size
        size = CGSize(width: size.width / 3.0 , height: size.height / 3.0)
        PHImageManager.default().requestImage(for: self.phasset, targetSize: size, contentMode: .aspectFit, options: options) {
            image,infoDict in
            img = image
        }
        return img
    }
    
    override func getImageAsync(complete:@escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        PHImageManager.default().requestImage(for: self.phasset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) {
            image,infoDict in
            complete(image)
        }
    }
    
    override func getVideoDurationAsync(complete:@escaping (Double) -> Void) {
        PHImageManager.default().requestAVAsset(forVideo: self.phasset, options: nil){
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
    
    override func getIdentity() -> String {
        return self.phasset.localIdentifier
    }
    
    private func fetchAVPlayerItemSync() -> AVPlayerItem? {
        var playerItem:AVPlayerItem?
        let sem = DispatchSemaphore(value: 0)
        PHImageManager.default().requestPlayerItem(forVideo: self.phasset, options: nil){
            item,infoDict in
            playerItem = item
            sem.signal()
        }
        sem.wait()
        return playerItem
    }
    
    private func fetchDataSync(complete:@escaping (NSData?, String?, UIImageOrientation, [AnyHashable : Any]?) -> Void) {
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        PHImageManager.default().requestImageData(for: self.phasset, options: requestOptions){
            (data,dataUTI,orientation,infoDict) in
            complete(data as NSData?, dataUTI, orientation, infoDict)
        }
    }
    
    
}

@available(iOS 8.0, *)
class MTImagePickerPhotosAlbumModel:MTImagePickerAlbumModel {
    
    private var result:PHFetchResult<AnyObject>
    private var _albumCount:Int
    private var _albumName:String?
    
    init(result:PHFetchResult<AnyObject>,albumCount:Int,albumName:String?) {
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
        if let asset = self.result.object(at: 0) as? PHAsset {
            let model = MTImagePickerPhotosModel(mediaType: .Photo, phasset: asset)
            return model.getThumbImage(size: size)
        }
        return nil
    }
    
    override func getMTImagePickerModelsListAsync(complete: @escaping ([MTImagePickerModel]) -> Void) {
        var models = [MTImagePickerModel]()
        DispatchQueue.global(qos: .default).async {
            self.result.enumerateObjects({ (asset, index, isStop) -> Void in
                if let phasset = asset as? PHAsset {
                    let mediaType:MTImagePickerMediaType = phasset.mediaType == .image ? .Photo : .Video
                    let model = MTImagePickerPhotosModel(mediaType: mediaType, phasset: phasset)
                    models.append(model)
                }
            })
            DispatchQueue.main.async {
                complete(models)
            }
        }
    }
}




