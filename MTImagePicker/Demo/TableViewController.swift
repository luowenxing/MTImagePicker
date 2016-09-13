//
//  ViewController.swift
//  MTImagePicker
//
//  Created by Luo on 5/23/16.
//  Copyright © 2016 Luo. All rights reserved.
//

import UIKit
import AssetsLibrary

class ViewController: UITableViewController,MTImagePickerControllerDelegate {

    private var dataSource = [MTImagePickerModel]()
    private var lib:ALAssetsLibrary!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundView = UIView()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 6
        } else {
            return dataSource.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = self.tableView.dequeueReusableCellWithIdentifier(String(indexPath.row), forIndexPath: indexPath)
            return cell
        } else {
            let model = self.dataSource[indexPath.row]
            let cell = self.tableView.dequeueReusableCellWithIdentifier("imageCell", forIndexPath: indexPath)
            // 不推荐的写法，此处为了简便所以这样实现
            let imageView = (cell.viewWithTag(1001) as! UIImageView)
            imageView.image = model.getThumbImage(imageView.frame.size)
            (cell.viewWithTag(1002) as! UILabel).text = model.getFileSize().byteFormat()
            (cell.viewWithTag(1003) as! UILabel).text = model.getFileName()
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 5 && indexPath.section == 0 {
            self.btnPickTouch()
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 44
        } else {
            return 100
        }
    }
    
    @available(iOS 8.0, *)
    func imagePickerController(picker: MTImagePickerController, didFinishPickingWithPhotosModels models: [MTImagePickerPhotosModel]) {
        self.dataSource = models
        self.tableView.reloadData()
    }
    
    func imagePickerController(picker: MTImagePickerController, didFinishPickingWithAssetsModels models: [MTImagePickerAssetsModel]) {
        self.dataSource = models
        self.tableView.reloadData()
    }
    
    
    
    func btnPickTouch() {
        // 不推荐的写法，此处为了简便所以这样实现。
        let textCount = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))?.viewWithTag(1001) as! UITextField
        let photoSwitch = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))?.viewWithTag(1001) as! UISwitch
        let videoSwitch = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))?.viewWithTag(1001) as! UISwitch
        let defaultAllSwitch = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0))?.viewWithTag(1001) as! UISwitch
        let sourceSwitch = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 4, inSection: 0))?.viewWithTag(1001) as! UISwitch
        var mediaTypes = [MTImagePickerMediaType]()
        var source = MTImagePickerSource.ALAsset
        var defaultAll = false
        if photoSwitch.on == true {
            mediaTypes.append(MTImagePickerMediaType.Photo)
        }
        if videoSwitch.on == true {
            mediaTypes.append(MTImagePickerMediaType.Video)
        }
        if sourceSwitch.on == false {
            source = MTImagePickerSource.Photos
        }
        if defaultAllSwitch.on == true {
            defaultAll = true
        }
        
        // 使用示例
        let vc = MTImagePickerController.instance
        vc.mediaTypes = mediaTypes
        vc.source = source
        vc.imagePickerDelegate = self
        if let text = textCount.text,maxCount = Int(text) {
            vc.maxCount = maxCount
        }
        vc.defaultAll = defaultAll
        self.presentViewController(vc, animated: true, completion: nil)
    }

}

