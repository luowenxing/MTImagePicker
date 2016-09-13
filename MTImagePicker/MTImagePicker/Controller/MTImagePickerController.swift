//
//  File.swift
//  MTImagePicker
//
//  Created by Luo on 9/9/16.
//  Copyright © 2016 Luo. All rights reserved.
//

import UIKit

@objc public enum MTImagePickerMediaType:Int {
    case Photo
    case Video
}


@objc public protocol MTImagePickerControllerDelegate:NSObjectProtocol {
    // Implement it when setting source to MTImagePickerSource.ALAsset
    optional func imagePickerController(picker:MTImagePickerController, didFinishPickingWithAssetsModels models:[MTImagePickerAssetsModel])
    
    // Implement it when setting source to MTImagePickerSource.Photos
    @available(iOS 8.0, *)
    optional func imagePickerController(picker:MTImagePickerController, didFinishPickingWithPhotosModels models:[MTImagePickerPhotosModel])
    
    optional func imagePickerControllerDidCancel(picker: MTImagePickerController)
}


public class MTImagePickerController:UINavigationController {

    public weak var imagePickerDelegate:MTImagePickerControllerDelegate? {
        get {
            return self._delegate
        }
        set {
            self._delegate = newValue
            self.albumController?.delegate = newValue
        }
    }
    
    public var mediaTypes:[MTImagePickerMediaType] {
        get {
            return self._mediaTypes
        }
        set {
            self._mediaTypes.removeAll()
            if newValue.contains(.Photo) {
                self._mediaTypes.append(.Photo)
            }
            if newValue.contains(.Video) {
                self._mediaTypes.append(.Video)
            }
            self.albumController?.mediaTypes = self._mediaTypes
        }
    }
    
    public var maxCount: Int {
        get {
            return self._maxCount
        }
        set {
            if newValue > 0 {
                self._maxCount = newValue
                self.albumController?.maxCount = newValue
            }
        }
    }
    
    public var defaultShowCameraRoll:Bool {
        get {
            return self._defaultAll
        }
        set {
            self._defaultAll = newValue
        }
    }
    public var source:MTImagePickerSource {
        get {
            return self._source
        }
        set {
            self._source = newValue
            if newValue == .Photos {
                if #available(iOS 8.0, *) {
                    
                } else {
                    self._source = .ALAsset
                }
            }
            self.albumController?.source = self._source
        }
    }
    
    public var mediaTypesNSArray:NSArray {
        get {
            let arr = NSMutableArray()
            for mediaType in self.mediaTypes {
                arr.addObject(mediaType.rawValue)
            }
            return arr
        }
        set {
            self.mediaTypes.removeAll()
            for mediaType in newValue {
                if let intType = mediaType as? Int {
                    if intType == 0 {
                        self.mediaTypes.append(.Photo)
                    } else if intType == 1 {
                        self.mediaTypes.append(.Video)
                    }
                }
            }
        }
    }
    
    public override func viewWillAppear(animated: Bool) {
        if self.defaultShowCameraRoll {
            let controller = MTImagePickerAssetsController.instance
            controller.delegate = self.imagePickerDelegate
            controller.maxCount = self.maxCount
            controller.source = self.source
            MTImagePickerDataSource.fetchDefault(self.source, mediaTypes: self.mediaTypes) {
                controller.groupModel = $0
                self.pushViewController(controller, animated: false)
            }
        }
    }
    
    class var instance:MTImagePickerController {
        get {
            let controller = MTImagePickerAlbumsController.instance
            let navigation = MTImagePickerController(rootViewController: controller)
            navigation.albumController = controller
            return navigation
        }
    }

    public weak var _delegate:MTImagePickerControllerDelegate?
    private var _mediaTypes = [MTImagePickerMediaType.Photo]
    private var _maxCount:Int = Int.max
    private var _defaultAll:Bool = true
    private var _source = MTImagePickerSource.ALAsset
    private weak var albumController:MTImagePickerAlbumsController?

}
