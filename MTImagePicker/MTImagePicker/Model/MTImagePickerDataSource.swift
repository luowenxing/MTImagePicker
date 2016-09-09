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
            MTImagePickerDataSource.fetchByALAsset(mediaTypes) { complete($0) }
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
            MTImagePickerDataSource.fetchByALAsset(mediaTypes) {
                if let model = ($0.maxElement { $0.getAlbumCount() < $1.getAlbumCount() }) {
                    complete(model)
                }
            }
        }
    }
    
    class func fetchByALAsset(mediaTypes:[MTImagePickerMediaType],complete:[MTImagePickerAlbumModel] -> Void) {
        var models = [MTImagePickerAlbumModel]()
        ALAsset.lib.enumerateGroupsWithTypes(ALAssetsGroupAll, usingBlock: {
            (Group, success) in
            if let group = Group {
                if group.numberOfAssets() > 0 {
                    let model = MTImagePickerAssetsAlbumModel(group: group, mediaTypes: mediaTypes)
                    models.append(model)
                }
            } else {
                print("stop")
                dispatch_async(dispatch_get_main_queue()) {
                    complete(models)
                }
            }
        }){
            (NSError) in
            MTImagePickerDataSource.showUnAuthorize()
        }
    }
    
    @available(iOS 8.0, *)
    class func fetchByPhotos(mediaTypes:[MTImagePickerMediaType],complete:[MTImagePickerAlbumModel] -> Void) {
        var models = [MTImagePickerAlbumModel]()
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "estimatedAssetCount > 0")
        let userAlbums = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.Album, subtype: PHAssetCollectionSubtype.Any, options: options)
        userAlbums.enumerateObjectsUsingBlock {
            if let collection = $0.0 as? PHAssetCollection {
                let model = MTImagePickerPhotosAlbumModel(collection: collection, mediaTypes: mediaTypes)
                models.append(model)
            }
        }
        complete(models)
    }
    
    class func showUnAuthorize() {
        dispatch_async(dispatch_get_main_queue()){
            let alertView = UIAlertView(title: "Notice".localized, message: "照片访问权限被禁用，请前往系统设置->隐私->照片中，启用本程序对照片的访问权限".localized, delegate: nil, cancelButtonTitle: "OK".localized)
            alertView.show()
        }
    }
}