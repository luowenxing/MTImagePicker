//
//  Extensions.swift
//  MTImagePicker
//
//  Created by Luo on 5/24/16.
//  Copyright © 2016 Luo. All rights reserved.
//

import Foundation
import UIKit
import AssetsLibrary

extension UIScreen {
    var compatibleBounds:CGRect{//iOS7 mainScreen bounds 不随设备旋转
        var rect = self.bounds
        if NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0 {
            let orientation = UIApplication.sharedApplication().statusBarOrientation
            if orientation.isLandscape{
                rect.size.width = self.bounds.height
                rect.size.height = self.bounds.width
            }
        }
        return rect
    }
}


extension ALAsset {
    class func getAssetFromUrlSync(lib:ALAssetsLibrary,url:NSURL) -> ALAsset? {
        let sema = dispatch_semaphore_create(0)
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)
        var result:ALAsset?
        dispatch_async(queue){
            lib.assetForURL(url, resultBlock: { (asset) in
                result = asset
                dispatch_semaphore_signal(sema)
                }, failureBlock: { (error) in
                    dispatch_semaphore_signal(sema)
            })
        }
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER)
        return result
    }
    
    class func getLib() -> ALAssetsLibrary? {
        let status = ALAssetsLibrary.authorizationStatus()
        if status == .Authorized || status == .NotDetermined {
            return ALAssetsLibrary()
        } else {
            dispatch_async(dispatch_get_main_queue()){
                let alertView = UIAlertView(title: "提示", message: "照片访问权限被禁用，请前往系统设置->隐私->照片中，启用本程序对照片的访问权限", delegate: nil, cancelButtonTitle: "确定")
                alertView.show()
            }
            return nil
        }
    }
    
}
extension Int {
    func byteFormat( places:UInt = 2 ) -> String {
        if self < 0 {
            return ""
        }
        else if self == 0 {
            return "0KB"
        }
        else if self < 1024 {
            return "1KB"
        }
        else if self < 1024 * 1024 { //KB
            return "\(self/1024)KB"
        }
        else if self < 1024 * 1024 * 1024 { //MB
            return "\(String(format: "%.\(places)f", Float(self) / 1024 / 1024))MB"
        }
        else {
            return "\(String(format: "%.\(places)f", Float(self) / 1024 / 1024 / 1024))GB"
        }
    }
}

extension UIView {
    func heartbeatsAnimation(duration:Double) {
        UIView.animateWithDuration(duration, animations: {
            self.transform = CGAffineTransformMakeScale(1.15, 1.15)
        }){
            _ in
            UIView.animateWithDuration(duration, animations: {
                self.transform = CGAffineTransformMakeScale(0.9, 0.9)
            }){
                _ in
                UIView.animateWithDuration(duration){
                    self.transform = CGAffineTransformMakeScale(1.0, 1.0)
                }
            }
        }
    }
}




