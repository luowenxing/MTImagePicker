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
import Photos



enum MTImagePickerMediaType {
    case Photo
    case Video
}

enum MTImagePickerSource {
    case ALAsset
    case Photos
}

@objc protocol MTImagePickerControllerDelegate:NSObjectProtocol {
    // Implement it when setting source to MTImagePickerSource.ALAsset
    optional func imagePickerController(picker:MTImagePickerController, didFinishPickingWithAssetsModels models:[MTImagePickerAssetsModel])
    
    // Implement it when setting source to MTImagePickerSource.Photos
    @available(iOS 8.0, *)
    optional func imagePickerController(picker:MTImagePickerController, didFinishPickingWithPhotosModels models:[MTImagePickerPhotosModel])
    
    optional func imagePickerControllerDidCancel(picker: MTImagePickerController)
}

class MTImagePickerController :UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {

    weak var delegate:MTImagePickerControllerDelegate?
    var mediaTypes:[MTImagePickerMediaType] = [.Photo]
    var maxCount: Int = Int.max
    // Default is ALAsset
    var source:MTImagePickerSource {
        get {
            return self._source
        }
        set {
            self._source = newValue
            if newValue == .Photos {
                if #available(iOS 8.0, *) {
                    
                } else {
                    self._source = .ALAsset
                }
            }
        }
    }
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lbSelected: UILabel!
    @IBOutlet weak var trailing: NSLayoutConstraint!
    @IBOutlet weak var leading: NSLayoutConstraint!
    @IBOutlet weak var btnPreview: UIButton!
    
    //MARK: data source
    private lazy var dataSource:[MTImagePickerModel] = {
        if self.source == .ALAsset {
            return self.alassetDataSource
        } else {
            if #available(iOS 8.0, *) {
                return self.photosDataSource
            }else {
                return self.alassetDataSource
            }
        }
    }()
    
    private lazy var alassetDataSource:[MTImagePickerAssetsModel] = {
        var dataSource = [MTImagePickerAssetsModel]()
        let loading = LoadingViewController()
        if let lib = self.lib {
            let failureblock:(NSError!) ->Void = {
                error in
                let alert = FlashAlertView(message: "Access photo library failed".localized)
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
                                let model = MTImagePickerAssetsModel(mediaType: mediaType, sortNumber: Index,source:.ALAsset,asset: result,lib:lib)
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
            loading.show("Loading...".localized)
            lib.enumerateGroupsWithTypes(ALAssetsGroupAll, usingBlock: libraryGroupsEnumeration , failureBlock:failureblock)
        }
        return dataSource
    }()
    

    @available(iOS 8.0, *)
    private lazy var photosDataSource:[MTImagePickerPhotosModel] = {
        var dataSource = [MTImagePickerPhotosModel]()
        let options = PHFetchOptions()
        var formats = [String]()
        var arguments = [Int]()
        for type in self.mediaTypes {
            formats.append("mediaType = %d")
            if type == .Photo {
                arguments.append(PHAssetMediaType.Image.rawValue)
            } else if type == .Video {
                arguments.append(PHAssetMediaType.Video.rawValue)
            }
        }
        options.predicate = NSPredicate(format: formats.joinWithSeparator(" or "), argumentArray: arguments)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let result = PHAsset.fetchAssetsWithOptions(options)
        let loading = LoadingViewController()
        loading.show("Loading...".localized)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
            result.enumerateObjectsUsingBlock(){
                (phassets, index, isStop) -> Void in
                let phasset = phassets as! PHAsset
                var mediaType:MTImagePickerMediaType = .Photo
                if phasset.mediaType == PHAssetMediaType.Image {
                    mediaType = .Photo
                }else {
                    mediaType = .Video
                }
                let model = MTImagePickerPhotosModel(mediaType: mediaType, sortNumber: index, source: .Photos, phasset: phasset)
                dataSource.append(model)
            }
            dispatch_async(dispatch_get_main_queue()){
                loading.dismiss()
                self.dataSource =  dataSource
                self.collectionView.reloadData()
                self.scrollToBottom()
            }
        }
        return dataSource
    }()
    
    
    private var selectedSource = Set<MTImagePickerModel>()
    private var initialScrollDone:Bool = false
    private lazy var lib = ALAsset.getLib()
    private var _source:MTImagePickerSource = .Photos
    
    class var instance:MTImagePickerController {
        get {
            let storyboard = UIStoryboard(name: "MTImagePicker", bundle: NSBundle.mainBundle())
            let vc = storyboard.instantiateViewControllerWithIdentifier("MTImagePickerController") as! MTImagePickerController
            return vc
        }
    }
    
    //MARK: Lifecycle
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
            model.getVideoDurationAsync(){
                duration in
                dispatch_async(dispatch_get_main_queue()){
                    cell.videoDuration.text = duration.timeFormat()
                }
            }
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
            let alertView = FlashAlertView(message: "Maxium selected".localized, delegate: nil)
            alertView.show()
        }
    }
    
    //MARK: private methods
    
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
        self.title = "All Photos".localized
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
    
    //MARK: IBActions
    @IBAction func btnFinishTouch(sender: AnyObject) {
        let dataSource = self.getSelectedSortedSource()
        if self.source == .Photos {
            if #available(iOS 8.0, *) {
                self.delegate?.imagePickerController?(self, didFinishPickingWithPhotosModels: dataSource as! [MTImagePickerPhotosModel])
            } else {
                // Fallback on earlier versions
            }
        } else {
            self.delegate?.imagePickerController?(self, didFinishPickingWithAssetsModels: dataSource as! [MTImagePickerAssetsModel])
        }
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
