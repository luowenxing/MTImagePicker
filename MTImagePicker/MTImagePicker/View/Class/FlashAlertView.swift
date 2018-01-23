//
//  FlashAlertView.swift
//  MTImagePicker
//
//  Created by Luo on 5/24/16.
//  Copyright © 2016 Luo. All rights reserved.
//

import UIKit

//
//  FlashAlertView.swift
//  CMBMobile
//
//  Created by Yst－WHB on 3/23/15.
//  Copyright (c) 2015 Yst－WHB. All rights reserved.
//

import UIKit

class FlashAlertView: UIAlertView {
    fileprivate var flashTime: TimeInterval = 1.25
    
    init(message: String, delegate: UIAlertViewDelegate? = nil) {
        self.init(title: nil, message: message, delegate: delegate, cancelButtonTitle: nil)
    }
    
    init(message: String, delegate: UIAlertViewDelegate? = nil, flashTime: TimeInterval) {
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
        DispatchQueue.main.async(execute: {
            super.show()
            Timer.scheduledTimer(timeInterval: self.flashTime, target: self, selector: #selector(FlashAlertView.hideAlertView), userInfo: nil, repeats: false)
        })
    }
    
    @objc func hideAlertView() {
        self.dismiss(withClickedButtonIndex: 0, animated: true)
    }
}
