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



@objc public enum MTImagePickerMediaType:Int {
    case Photo
    case Video
}

@objc public enum MTImagePickerSource:Int {
    case ALAsset
    case Photos
}

@objc public  protocol MTImagePickerControllerDelegate:NSObjectProtocol {
    // Implement it when setting source to MTImagePickerSource.ALAsset
    optional func imagePickerController(picker:MTImagePickerController, didFinishPickingWithAssetsModels models:[MTImagePickerAssetsModel])
    
    // Implement it when setting source to MTImagePickerSource.Photos
    @available(iOS 8.0, *)
    optional func imagePickerController(picker:MTImagePickerController, didFinishPickingWithPhotosModels models:[MTImagePickerPhotosModel])
    
    optional func imagePickerControllerDidCancel(picker: MTImagePickerController)
}

public class MTImagePickerController :UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
    
    public weak var delegate:MTImagePickerControllerDelegate?
    public var mediaTypes:[MTImagePickerMediaType] = [MTImagePickerMediaType.Photo]
    // OC project support,for [MTImagePickerMediaType] can not be represented in OC Class
    public var mediaTypesNSArray:NSArray {
        get {
            let arr = NSMutableArray()
            for mediaType in self.mediaTypes {
                arr.addObject(mediaType.rawValue)
            }
            return arr
        }
        set {
            self.mediaTypes.removeAll()
            for mediaType in newValue {
                if let intType = mediaType as? Int {
                    if intType == 0 {
                        self.mediaTypes.append(.Photo)
                    } else if intType == 1 {
                        self.mediaTypes.append(.Video)
                    }
                }
            }
        }
    }
    
    public var maxCount: Int = Int.max
    // Default is ALAsset
    public var source:MTImagePickerSource {
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
    
    @IBOutlet weak var collectionView: MTImagePickerCollectionView!
    @IBOutlet weak var lbSelected: UILabel!
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
        if let lib = ALAsset.getLib(self.showUnAuthorize) {
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
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .Authorized || status == .NotDetermined {
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
        } else {
            self.showUnAuthorize()
        }
        return dataSource
    }()
    
    
    private var selectedSource = Set<MTImagePickerModel>()
    private var initialScrollDone:Bool = false
    private var _source:MTImagePickerSource = .Photos
    
    public class var instance:MTImagePickerController {
        get {
            let storyboard = UIStoryboard(name: "MTImagePicker", bundle: NSBundle.mainBundle())
            let vc = storyboard.instantiateViewControllerWithIdentifier("MTImagePickerController") as! MTImagePickerController
            return vc
        }
    }
    
    //MARK: Lifecycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
        self.lbSelected.text = String(self.selectedSource.count)
        self.btnPreview.enabled = !(self.selectedSource.count == 0)
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !self.initialScrollDone {
            self.initialScrollDone = true
            self.scrollToBottom()
        }
    }
    
    //MARK: UICollectionViewDelegate
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
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
        cell.leading.constant = self.collectionView.leading.constant
        cell.trailing.constant = self.collectionView.leading.constant
        cell.top.constant = self.collectionView.leading.constant * 2
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
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
    
    func showUnAuthorize() {
        dispatch_async(dispatch_get_main_queue()){
            let alertView = UIAlertView(title: "Notice".localized, message: "照片访问权限被禁用，请前往系统设置->隐私->照片中，启用本程序对照片的访问权限", delegate: nil, cancelButtonTitle: "OK".localized)
            alertView.show()
        }
    }
    
    //旋转处理
    override public func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if self.interfaceOrientation.isPortrait != toInterfaceOrientation.isPortrait {
            self.collectionView.prevItemSize = (self.collectionView.collectionViewLayout as! MTImagePickerFlowLayout).itemSize
            self.collectionView.prevOffset = self.collectionView.contentOffset.y
            self.collectionView.collectionViewLayout.invalidateLayout()
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

class MTImagePickerCollectionView:UICollectionView {
    @IBOutlet weak var trailing: NSLayoutConstraint!
    @IBOutlet weak var leading: NSLayoutConstraint!
    var prevItemSize:CGSize?
    var prevOffset:CGFloat = 0
}
