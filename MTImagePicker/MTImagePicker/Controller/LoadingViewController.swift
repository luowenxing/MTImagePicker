//
//  LoadingViewController.swift
//  CMBMobile
//
//  Created by LUO on 3/14/16.
//  Copyright © 2016 Yst－WHB. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

    //use UIWindow show modal dialog
    var newWindow:UIWindow?
    
    func show(){
        if self.newWindow == nil{
            let uiwindow = UIWindow(frame: UIScreen.mainScreen().bounds)
            uiwindow.rootViewController = self
            uiwindow.hidden = false
            uiwindow.backgroundColor = UIColor.clearColor()
            self.newWindow = uiwindow
        }
    }
    
    func dismiss(){
        self.newWindow?.rootViewController = nil
        self.newWindow = nil
    }

    
    private var titleLabel:UILabel = UILabel()
    
    override func viewDidLoad() {
        let loadingView = UIView()
        let spining = UIActivityIndicatorView()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        loadingView.layer.cornerRadius = 10
        spining.startAnimating()
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        spining.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont.boldSystemFontOfSize(16)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let viewConstraints = [
            NSLayoutConstraint(item: loadingView, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: -20),
            NSLayoutConstraint(item: loadingView, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0)]
        view.addSubview(loadingView)
        view.addConstraints(viewConstraints)
    
        let loadingViewConstraints = [
            NSLayoutConstraint(item: spining , attribute: .CenterX, relatedBy: .Equal, toItem: loadingView , attribute: .CenterX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: spining , attribute: .Top, relatedBy: .Equal, toItem: loadingView , attribute: .Top, multiplier: 1, constant: 14),
            NSLayoutConstraint(item: titleLabel , attribute: .CenterX, relatedBy: .Equal, toItem: loadingView , attribute: .CenterX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: titleLabel , attribute: .Top, relatedBy: .Equal, toItem: spining , attribute: .Bottom, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: titleLabel , attribute: .Leading, relatedBy: .Equal, toItem: loadingView , attribute: .Leading, multiplier: 1, constant: 14),
            NSLayoutConstraint(item: loadingView , attribute: .Bottom, relatedBy: .Equal, toItem: titleLabel , attribute: .Bottom, multiplier: 1, constant: 14)
        ]
        loadingView.addSubview(spining)
        loadingView.addSubview(titleLabel)
        loadingView.addConstraints(loadingViewConstraints)
    }
    
    func show(text:String) {
        self.show()
        self.titleLabel.text = text
    }
}
