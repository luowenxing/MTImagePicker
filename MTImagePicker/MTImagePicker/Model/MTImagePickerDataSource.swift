//
//  MTImagePickerDataSource.swift
//  MTImagePicker
//
//  Created by Luo on 9/6/16.
//  Copyright © 2016 Luo. All rights reserved.
//

import Foundation
import Photos
import AssetsLibrary

@objc public enum MTImagePickerSource:Int {
    case ALAsset
    case Photos
}

class MTImagePickerDataSource {
    
    class func fetch(type:MTImagePickerSource,mediaTypes:[MTImagePickerMediaType],complete:[MTImagePickerAlbumModel] -> Void) {
        if type == .ALAsset {
            MTImagePickerDataSource.fetchByALAsset(mediaTypes) { complete($0) }
        } else if type == .Photos {
            if #available(iOS 8.0, *) {
                
                MTImagePickerDataSource.fetchByPhotos(mediaTypes) { complete($0) }
            }
        }
    }
    
    // 可优化 这里简单复用代码，取数量最多的group作为默认所有相片的group
    class func fetchDefault(type:MTImagePickerSource,mediaTypes:[MTImagePickerMediaType],complete:MTImagePickerAlbumModel -> Void) {
        if type == .ALAsset {
            MTImagePickerDataSource.fetchByALAsset(mediaTypes) {
                if let model = ($0.maxElement { $0.getAlbumCount() < $1.getAlbumCount() }) {
                    complete(model)
                }
            }
        } else if type == .Photos {
            if #available(iOS 8.0, *) {
                MTImagePickerDataSource.fetchByPhotos(mediaTypes) {
                    if let model = ($0.maxElement { $0.getAlbumCount() < $1.getAlbumCount() }) {
                        complete(model)
                    }
                }
            }
        }
    }
    
    class func fetchByALAsset(mediaTypes:[MTImagePickerMediaType],complete:[MTImagePickerAlbumModel] -> Void) {
        
        var models = [MTImagePickerAlbumModel]()
        ALAsset.lib.enumerateGroupsWithTypes(ALAssetsGroupAll|ALAssetsGroupLibrary, usingBlock: {
            (Group, success) in
            if let group = Group {
                var filter:ALAssetsFilter?
                let containsPhoto = mediaTypes.contains(.Photo)
                let containsVideo = mediaTypes.contains(.Video)
                filter = containsPhoto ? ALAssetsFilter.allPhotos() : filter
                filter = containsVideo ? ALAssetsFilter.allVideos() : filter
                filter = containsPhoto && containsVideo ? ALAssetsFilter.allAssets() : filter
                if let Fliter = filter {
                    group.setAssetsFilter(Fliter)
                }
                if group.numberOfAssets() > 0 {
                    let model = MTImagePickerAssetsAlbumModel(group: group)
                    models.insert(model, atIndex: 0)
                }
            } else {
                complete(models)
            }
        }){
            (NSError) in
            MTImagePickerDataSource.showUnAuthorize()
        }
    }
    
    @available(iOS 8.0, *)
    class func fetchByPhotos(mediaTypes:[MTImagePickerMediaType],complete:[MTImagePickerAlbumModel] -> Void) {
        
        func chargeAuthorizationStatus(status: PHAuthorizationStatus,onAuthorized:() -> Void) {
            switch (status) {
            case .Authorized:
                onAuthorized()
            case .Denied:
                MTImagePickerDataSource.showUnAuthorize()
                break
            case .Restricted:
                MTImagePickerDataSource.showUnAuthorize()
                break
            case .NotDetermined:
                PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                    guard status != .NotDetermined else {
                        return
                    }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        chargeAuthorizationStatus(status,onAuthorized: onAuthorized )
                    })
                })
            }
        }
        
        chargeAuthorizationStatus(PHPhotoLibrary.authorizationStatus()) {
            var models = [MTImagePickerAlbumModel]()
            func fetchAlbums() -> [PHFetchResult] {
                let userAlbumsOptions = PHFetchOptions()
                userAlbumsOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
                userAlbumsOptions.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
                var albums = [PHFetchResult]()
                albums.append(
                    PHAssetCollection.fetchAssetCollectionsWithType(
                        PHAssetCollectionType.SmartAlbum,
                        subtype: PHAssetCollectionSubtype.AlbumRegular,
                        options: nil)
                )
                albums.append(
                    PHAssetCollection.fetchAssetCollectionsWithType(
                        PHAssetCollectionType.Album,
                        subtype: PHAssetCollectionSubtype.Any,
                        options: userAlbumsOptions)
                )
                return albums
            }
            
            let results = fetchAlbums()
            let options = PHFetchOptions()
            var formats = [String]()
            var arguments = [Int]()
            for type in mediaTypes {
                formats.append("mediaType = %d")
                if type == .Photo {
                    arguments.append(PHAssetMediaType.Image.rawValue)
                } else if type == .Video {
                    arguments.append(PHAssetMediaType.Video.rawValue)
                }
            }
            options.predicate = NSPredicate(format: formats.joinWithSeparator(" or "), argumentArray: arguments)
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            for (_, result) in results.enumerate() {
                result.enumerateObjectsUsingBlock({ (collection, index, isStop) -> Void in
                    let album = collection as! PHAssetCollection
                    let assetResults = PHAsset.fetchAssetsInAssetCollection(album, options: options)
                    var count = 0
                    switch album.assetCollectionType {
                    case .Album:
                        count = assetResults.count
                    case .SmartAlbum:
                        count = assetResults.count
                    case .Moment:
                        count = 0
                    }
                    if count > 0 {
                        let model = MTImagePickerPhotosAlbumModel(result: assetResults, albumCount: count, albumName: album.localizedTitle)
                        models.append(model)
                    }
                })
            }
            complete(models)
        }
    }
    
    
    
    class func showUnAuthorize() {
        dispatch_async(dispatch_get_main_queue()){
            let alertView = UIAlertView(title: "Notice".localized, message: "照片访问权限被禁用，请前往系统设置->隐私->照片中，启用本程序对照片的访问权限".localized, delegate: nil, cancelButtonTitle: "OK".localized)
            alertView.show()
        }
    }
}