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
            let uiwindow = UIWindow(frame: UIScreen.main.bounds)
            uiwindow.rootViewController = self
            uiwindow.isHidden = false
            uiwindow.backgroundColor = UIColor.clear
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
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let viewConstraints = [
            NSLayoutConstraint(item: loadingView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: -20),
            NSLayoutConstraint(item: loadingView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)]
        view.addSubview(loadingView)
        view.addConstraints(viewConstraints)
    
        let loadingViewConstraints = [
            NSLayoutConstraint(item: spining , attribute: .centerX, relatedBy: .equal, toItem: loadingView , attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: spining , attribute: .top, relatedBy: .equal, toItem: loadingView , attribute: .top, multiplier: 1, constant: 14),
            NSLayoutConstraint(item: titleLabel , attribute: .centerX, relatedBy: .equal, toItem: loadingView , attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: titleLabel , attribute: .top, relatedBy: .equal, toItem: spining , attribute: .bottom, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: titleLabel , attribute: .leading, relatedBy: .equal, toItem: loadingView , attribute: .leading, multiplier: 1, constant: 14),
            NSLayoutConstraint(item: loadingView , attribute: .bottom, relatedBy: .equal, toItem: titleLabel , attribute: .bottom, multiplier: 1, constant: 14)
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
