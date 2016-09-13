//
//  MTImagePickerAlbumController.swift
//  MTImagePicker
//
//  Created by Luo on 9/6/16.
//  Copyright © 2016 Luo. All rights reserved.
//

import UIKit
import AssetsLibrary

class MTImagePickerAlbumCell:UITableViewCell {
    
    @IBOutlet weak var lbAlbumCount: UILabel!
    @IBOutlet weak var lbAlbumName: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    
    func setup(model:MTImagePickerAlbumModel) {
        self.lbAlbumCount.text = "(\(model.getAlbumCount()))"
        self.lbAlbumName.text = model.getAlbumName()
        self.posterImageView.image = model.getAlbumImage(self.posterImageView.frame.size)
    }
}

class MTImagePickerAlbumsController :UITableViewController {
    
    var mediaTypes:[MTImagePickerMediaType] = [MTImagePickerMediaType.Photo]
    var source:MTImagePickerSource = .ALAsset
    var maxCount:Int = Int.max
    weak var delegate:MTImagePickerControllerDelegate?
    
    private var dataSource = [MTImagePickerAlbumModel]()
    private var _source:MTImagePickerSource = .Photos
    
    class var instance:MTImagePickerAlbumsController {
        get {
            let storyboard = UIStoryboard(name: "MTImagePicker", bundle: NSBundle.mainBundle())
            let vc = storyboard.instantiateViewControllerWithIdentifier("MTImagePickerAlbumsController") as! MTImagePickerAlbumsController
            return vc
        }
    }
    
    override func viewDidLoad() {
        self.tableView.tableFooterView = UIView()
        MTImagePickerDataSource.fetch(self.source, mediaTypes: self.mediaTypes, complete: { (dataSource) in
            self.dataSource = dataSource
            self.tableView.reloadData()
        })
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let model = self.dataSource[indexPath.row]
        let cell = self.tableView.dequeueReusableCellWithIdentifier("MTImagePickerAlbumCell", forIndexPath: indexPath)
        (cell as? MTImagePickerAlbumCell)?.setup(model)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let model = self.dataSource[indexPath.row]
        self.pushToMTImagePickerController(model,animate: true)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func pushToMTImagePickerController(model:MTImagePickerAlbumModel,animate:Bool) {
        let controller = MTImagePickerAssetsController.instance
        controller.groupModel = model
        controller.delegate = self.delegate
        controller.maxCount = self.maxCount
        controller.source = self.source
        self.navigationController?.pushViewController(controller, animated: animate)
    }
    @IBAction func btnCancelTouch(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

