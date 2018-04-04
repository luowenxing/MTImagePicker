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
    @objc optional func imagePickerController(picker:MTImagePickerController, didFinishPickingWithAssetsModels models:[MTImagePickerAssetsModel])
    
    // Implement it when setting source to MTImagePickerSource.Photos
    @available(iOS 8.0, *)
    @objc optional func imagePickerController(picker:MTImagePickerController, didFinishPickingWithPhotosModels models:[MTImagePickerPhotosModel])
    
    @objc optional func imagePickerControllerDidCancel(picker: MTImagePickerController)
}

public class MTImagePickerController:UINavigationController {
    
    public weak var imagePickerDelegate:MTImagePickerControllerDelegate?
    public var mediaTypes:[MTImagePickerMediaType]  = [.Photo]
    public var maxCount: Int = Int.max
    public var defaultShowCameraRoll:Bool = true
    public var selectedSource = [MTImagePickerModel]()
    private var _source = MTImagePickerSource.ALAsset
    public var source:MTImagePickerSource {
        get {
            return self._source
        }
        set {
            self._source = newValue
            // 只有iOS8以上才能使用Photos框架
            if newValue == .Photos {
                if #available(iOS 8.0, *) {
                    
                } else {
                    self._source = .ALAsset
                }
            }
        }
    }
    
    public var mediaTypesNSArray:NSArray {
        get {
            let arr = NSMutableArray()
            for mediaType in self.mediaTypes {
                arr.add(mediaType.rawValue)
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
    
    public override func viewWillAppear(_ animated: Bool) {
        if self.defaultShowCameraRoll {
            let controller = MTImagePickerAssetsController.instance
            controller.delegate = self
            MTImagePickerDataSource.fetchDefault(type: self.source, mediaTypes: self.mediaTypes) {
                controller.groupModel = $0
                self.pushViewController(controller, animated: false)
            }
        }
    }

    public class var instance:MTImagePickerController {
        get {
            let controller = MTImagePickerAlbumsController.instance
            let navigation = MTImagePickerController(rootViewController: controller)
            controller.delegate = navigation
            return navigation
        }
    }
}

protocol MTImagePickerDataSourceDelegate:NSObjectProtocol {
    var selectedSource:[MTImagePickerModel] { get set }
    var maxCount:Int { get }
    var mediaTypes:[MTImagePickerMediaType] { get }
    var source:MTImagePickerSource { get }
    func didFinishPicking()
    func didCancel()
}

extension MTImagePickerController:MTImagePickerDataSourceDelegate {
    
    func didFinishPicking() {
        if self.source == .Photos {
            if #available(iOS 8.0, *) {
                self.imagePickerDelegate?.imagePickerController?(picker:self, didFinishPickingWithPhotosModels: selectedSource as! [MTImagePickerPhotosModel])
            } else {
                // Fallback on earlier versions
            }
        } else {
            self.imagePickerDelegate?.imagePickerController?(picker:self, didFinishPickingWithAssetsModels: selectedSource as! [MTImagePickerAssetsModel])
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func didCancel() {
        imagePickerDelegate?.imagePickerControllerDidCancel?(picker: self)
        self.dismiss(animated: true, completion: nil)
    }

}


