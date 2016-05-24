//
//  ViewController.swift
//  MTImagePicker
//
//  Created by Luo on 5/23/16.
//  Copyright © 2016 Luo. All rights reserved.
//

import UIKit

class ViewController: UITableViewController,MTImagePickerControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func imagePickerController(picker: MTImagePickerController, didFinishPickingWithModels models: [MTImagePickerModel]) {
        for model in models {
            
        }
    }
    
    @IBAction func btnPickTouch(sender: AnyObject) {
        let vc = MTImagePickerController.instance
        vc.mediaTypes.append(MTImagePickerMediaType.Video)
        vc.delegate = self
        let nc = UINavigationController(rootViewController: vc)
        self.presentViewController(nc, animated: true, completion: nil)
    }

}

