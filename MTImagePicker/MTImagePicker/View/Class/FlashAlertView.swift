//
//  FlashAlertView.swift
//  MTImagePicker
//
//  Created by Luo on 5/24/16.
//  Copyright © 2016 Luo. All rights reserved.
//

import UIKit

class FlashAlertView: UIAlertView {
    private var flashTime: NSTimeInterval = 1.25
    
    init(message: String, delegate: UIAlertViewDelegate? = nil) {
        self.init(title: nil, message: message, delegate: delegate, cancelButtonTitle: nil)
    }
    
    init(message: String, delegate: UIAlertViewDelegate? = nil, flashTime: NSTimeInterval) {
        self.init(title: nil, message: message, delegate: delegate, cancelButtonTitle: nil)
        self.flashTime = flashTime
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func show() {
        dispatch_async(dispatch_get_main_queue(), {
            super.show()
            NSTimer.scheduledTimerWithTimeInterval(self.flashTime, target: self, selector: #selector(FlashAlertView.hideAlertView), userInfo: nil, repeats: false)
        })
    }
    
    func hideAlertView() {
        self.dismissWithClickedButtonIndex(0, animated: true)
    }
}