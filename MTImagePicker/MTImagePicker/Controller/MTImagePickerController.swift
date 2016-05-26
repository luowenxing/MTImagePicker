//
//  ImageSelectorViewController.swift
//  CMBMobile
//
//  Created by Luo on 5/9/16.
//  Copyright © 2016 Yst－WHB. All rights reserved.
//

import UIKit
import AssetsLibrary
import CoreImage
import Foundation



enum MTImagePickerMediaType {
    case Photo
    case Video
}

@objc protocol MTImagePickerControllerDelegate:NSObjectProtocol {
    optional func imagePickerController(picker:MTImagePickerController, didFinishPickingWithModels models:[MTImagePickerModel])
    optional func imagePickerControllerDidCancel(picker: MTImagePickerController)
}

class MTImagePickerController :UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {

    var mediaTypes:[MTImagePickerMediaType] = [.Photo]
    var maxCount: Int = Int.max
    var ALAssetGroup:UInt32 = ALAssetsGroupAll
    weak var delegate:MTImagePickerControllerDelegate?
    lazy var lib = ALAsset.getLib()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lbSelected: UILabel!
    @IBOutlet weak var trailing: NSLayoutConstraint!
    @IBOutlet weak var leading: NSLayoutConstraint!
    @IBOutlet weak var btnPreview: UIButton!
    
    //MARK: 数据源
    private lazy var dataSource:[MTImagePickerModel] = {
        var dataSource = [MTImagePickerModel]()
        let loading = LoadingViewController()
        if let lib = self.lib {
            let failureblock:(NSError!) ->Void = {
                error in
                let alert = FlashAlertView(message: "访问系统相册失败")
                alert.show()
                loading.dismiss()
            }
            
            let libraryGroupsEnumeration:(ALAssetsGroup!,UnsafeMutablePointer<ObjCBool>)->Void = {
                Group,Stop in
                if let group = Group where group.numberOfAssets() > 0{
                    group.enumerateAssetsUsingBlock(){
                        Result, Index, Stop in
                        if let result = Result {
                            let ALAssetType = result.valueForProperty(ALAssetPropertyType) as! NSString
                            var mediaType = MTImagePickerMediaType.Photo
                            var isValid = false
                            for type in self.mediaTypes {
                                if type == .Photo {
                                    if ALAssetType.isEqualToString(ALAssetTypePhoto) {
                                        isValid = true
                                        mediaType = .Photo
                                    }
                                } else if type == .Video {
                                    if ALAssetType.isEqualToString(ALAssetTypeVideo) {
                                        isValid = true
                                        mediaType = .Video
                                    }
                                }
                            }
                            if isValid {
                                let model = MTImagePickerModel(mediaType: mediaType, sortNumber: Index,asset: result,lib:lib)
                                dataSource.append(model)
                            }
                        }
                    }
                    loading.dismiss()
                    self.dataSource =  dataSource
                    self.collectionView.reloadData()
                    self.scrollToBottom()
                }
            }
            loading.show("正在加载...")
            lib.enumerateGroupsWithTypes(ALAssetsGroupAll, usingBlock: libraryGroupsEnumeration , failureBlock:failureblock)
        }
        return dataSource
    }()
    private var selectedSource = Set<MTImagePickerModel>()
    private var initialScrollDone:Bool = false
    
    class var instance:MTImagePickerController {
        get {
            let storyboard = UIStoryboard(name: "MTImagePicker", bundle: NSBundle.mainBundle())
            let vc = storyboard.instantiateViewControllerWithIdentifier("MTImagePickerController") as! MTImagePickerController
            return vc
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
        self.lbSelected.text = String(self.selectedSource.count)
        self.btnPreview.enabled = !(self.selectedSource.count == 0)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !self.initialScrollDone {
            self.initialScrollDone = true
            self.scrollToBottom()
        }
    }
    
    //MARK: UICollectionViewDelegate

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! MTImagePickerCell
        let model = self.dataSource[indexPath.row]
        if model.mediaType == .Video   {
            cell.videoView.hidden = false
            cell.videoDuration.text = model.getVideoDuration()
        } else {
            cell.videoView.hidden = true
        }
        cell.imageView.image = model.getThumbImage()
        cell.indexPath = indexPath
        cell.btnCheck.selected = self.selectedSource.contains(model)
        cell.btnCheck.addTarget(self, action: #selector(MTImagePickerController.btnCheckTouch(_:)), forControlEvents: .TouchUpInside)
        cell.leading.constant = self.leading.constant
        cell.trailing.constant = self.leading.constant
        cell.top.constant = self.leading.constant * 2
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.pushToImageSelectorPreviewController(indexPath, dataSource: self.dataSource)

    }
    
    func btnCheckTouch(sender:UIButton) {
        if self.selectedSource.count < self.maxCount || sender.selected == true {
            sender.selected = !sender.selected
            let indexPath = (sender.superview?.superview as! MTImagePickerCell).indexPath
            if sender.selected {
                self.selectedSource.insert(self.dataSource[indexPath.row])
                sender.heartbeatsAnimation(0.15)
            }else {
                self.selectedSource.remove(self.dataSource[indexPath.row])
            }
            self.lbSelected.text = String(self.selectedSource.count)
            self.lbSelected.heartbeatsAnimation(0.15)
            self.btnPreview.enabled = !(self.selectedSource.count == 0)
        } else {
            let alertView = FlashAlertView(message: "已经达到最大选择数", delegate: nil)
            alertView.show()
        }
    }
    
    private func scrollToBottom() {
        if self.dataSource.count > 0 {
            let indexPath = NSIndexPath(forRow: self.dataSource.count - 1 , inSection: 0)
            self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .None, animated: false)
        }
    }
    
    private func initUI() {
        let layout = (self.collectionView.collectionViewLayout as! MTImagePickerFlowLayout)
        layout.prepareLayout()
        self.trailing.constant = layout.space / 2.0
        self.leading.constant = self.trailing.constant
        self.title = "所有照片"
    }
    
    private func pushToImageSelectorPreviewController(initialIndexPath:NSIndexPath?,dataSource:[MTImagePickerModel]) {
        let vc = MTImagePickerPreviewController.instance
        vc.dataSource = dataSource
        vc.selectedSource = self.selectedSource
        vc.initialIndexPath = initialIndexPath
        vc.maxCount = self.maxCount
        vc.dismiss = {
            selectedSource in
            self.selectedSource = selectedSource
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func getSelectedSortedSource() -> [MTImagePickerModel] {
        var dataSource = [MTImagePickerModel]()
        for model in self.selectedSource.sort({ return $0.sortNumber < $1.sortNumber}) {
            dataSource.append(model)
        }
        return dataSource
    }
    
    
    @IBAction func btnFinishTouch(sender: AnyObject) {
        let dataSource = self.getSelectedSortedSource()
        self.delegate?.imagePickerController?(self, didFinishPickingWithModels: dataSource)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnPreviewTouch(sender: AnyObject) {
        let dataSource = self.getSelectedSortedSource()
        self.pushToImageSelectorPreviewController(nil, dataSource: dataSource)
    }
    @IBAction func btnCancelTouch(sender: AnyObject) {
        self.delegate?.imagePickerControllerDidCancel?(self)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func btnClearTouch(sender: AnyObject) {
        self.selectedSource.removeAll()
        self.collectionView.reloadData()
        self.lbSelected.text = String(self.selectedSource.count)
        self.btnPreview.enabled = false
    }
}
