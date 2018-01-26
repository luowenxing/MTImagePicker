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
            let orientation = UIApplication.shared.statusBarOrientation
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
        let sema = DispatchSemaphore(value: 0)
        var result:ALAsset?
        DispatchQueue.global().async {
            lib.asset(for: url as URL!, resultBlock: { (asset) in
                result = asset
                sema.signal()
            }, failureBlock: { (error) in
                sema.signal()
            })
        }
        sema.wait()
        return result
    }
    
    class func getLib(failure:()->Void) -> ALAssetsLibrary? {
        let status = ALAssetsLibrary.authorizationStatus()
        if status == .authorized || status == .notDetermined {
            return ALAssetsLibrary()
        } else {
            failure()
            return nil
        }
    }
    
     @nonobjc static let lib:ALAssetsLibrary = ALAssetsLibrary()
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

extension Double {
    func timeFormat() -> String {
        let ticks = Int(self)
        let text = String(format: "%d:%02d",ticks/60,ticks%60)
        return text
    }
}

extension UIView {
    func heartbeatsAnimation(duration:Double) {
        UIView.animate(withDuration: duration, animations: {
            self.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        }){
            _ in
            UIView.animate(withDuration: duration, animations: {
                self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }){
                _ in
                UIView.animate(withDuration: duration){
                    self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }
            }
        }
    }
}

extension String {
    var localized:String {
        return NSLocalizedString(self, comment: "")
    }
}




