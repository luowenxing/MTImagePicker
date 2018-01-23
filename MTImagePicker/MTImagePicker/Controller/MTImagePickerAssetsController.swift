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


class MTImagePickerAssetsController :UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
    
    weak var delegate:MTImagePickerControllerDelegate?
    var maxCount: Int = Int.max
    var groupModel:MTImagePickerAlbumModel!
    var source:MTImagePickerSource = .ALAsset
    
    @IBOutlet weak var collectionView: MTImagePickerCollectionView!
    @IBOutlet weak var lbSelected: UILabel!
    @IBOutlet weak var btnPreview: UIButton!
    
    private var dataSource = [MTImagePickerModel]()
    private var selectedSource = Set<MTImagePickerModel>()
    private var initialScrollDone:Bool = false
    private var navigation:MTImagePickerController {
        get {
            return self.navigationController as! MTImagePickerController
        }
    }
    
    class var instance:MTImagePickerAssetsController {
        get {
            let storyboard = UIStoryboard(name: "MTImagePicker", bundle: Bundle.main)
            let vc = storyboard.instantiateViewController(withIdentifier: "MTImagePickerController") as! MTImagePickerAssetsController
            return vc
        }
    }
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let loading = LoadingViewController()
        loading.show(text: "Loading...".localized)
        if let title = self.groupModel.getAlbumName() {
            self.title = title
        }
        self.groupModel?.getMTImagePickerModelsListAsync { (models) in
            loading.dismiss()
            self.dataSource = models
            self.collectionView.reloadData()
            self.scrollToBottom()
        }
        
        self.initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
        self.lbSelected.text = String(self.selectedSource.count)
        self.btnPreview.isEnabled = !(self.selectedSource.count == 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !self.initialScrollDone {
            self.initialScrollDone = true
            self.scrollToBottom()
        }
    }
    
    //MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! MTImagePickerCell
        let model = self.dataSource[indexPath.row]
        if model.mediaType == .Video   {
            cell.videoView.isHidden = false
            model.getVideoDurationAsync(){
                duration in
                DispatchQueue.main.async {
                    cell.videoDuration.text = duration.timeFormat()

                }
            }
        } else {
            cell.videoView.isHidden = true
        }
        cell.imageView.image = model.getThumbImage(size: cell.imageView.frame.size)
        cell.indexPath = indexPath
        cell.btnCheck.isSelected = self.selectedSource.contains(model)
        cell.btnCheck.addTarget(self, action: #selector(MTImagePickerAssetsController.btnCheckTouch(_:)), for: .touchUpInside)
        cell.leading.constant = self.collectionView.leading.constant
        cell.trailing.constant = self.collectionView.leading.constant
        cell.top.constant = self.collectionView.leading.constant * 2
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.pushToImageSelectorPreviewController(initialIndexPath: indexPath, dataSource: self.dataSource)
        
    }
    
    @objc func btnCheckTouch(_ sender:UIButton) {
        if self.selectedSource.count < self.maxCount || sender.isSelected == true {
            sender.isSelected = !sender.isSelected
            let indexPath = (sender.superview?.superview as! MTImagePickerCell).indexPath
            if sender.isSelected {
                self.selectedSource.insert(self.dataSource[(indexPath?.row)!])
                sender.heartbeatsAnimation(duration: 0.15)
            }else {
                self.selectedSource.remove(self.dataSource[(indexPath?.row)!])
            }
            self.lbSelected.text = String(self.selectedSource.count)
            self.lbSelected.heartbeatsAnimation(duration: 0.15)
            self.btnPreview.isEnabled = !(self.selectedSource.count == 0)
        } else {
            let alertView = FlashAlertView(message: "Maxium selected".localized, delegate: nil)
            alertView.show()
        }
    }
    
    func showUnAuthorize() {
        DispatchQueue.main.async {
            let alertView = UIAlertView(title: "Notice".localized, message: "照片访问权限被禁用，请前往系统设置->隐私->照片中，启用本程序对照片的访问权限", delegate: nil, cancelButtonTitle: "OK".localized)
            alertView.show()
        }
    }
    
    //旋转处理
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        if self.interfaceOrientation.isPortrait != toInterfaceOrientation.isPortrait {
            self.collectionView.prevItemSize = (self.collectionView.collectionViewLayout as! MTImagePickerFlowLayout).itemSize
            self.collectionView.prevOffset = self.collectionView.contentOffset.y
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    //MARK: private methods
    
    private func scrollToBottom() {
        if self.dataSource.count > 0 {
            let indexPath = IndexPath(row: self.dataSource.count - 1 , section: 0)
            self.collectionView.scrollToItem(at: indexPath, at:.bottom, animated: false)
        }
    }
    
    private func initUI() {
        self.title = "All Photos".localized
    }
    
    private func pushToImageSelectorPreviewController(initialIndexPath:IndexPath?,dataSource:[MTImagePickerModel]) {
        let vc = MTImagePickerPreviewController.instance
        vc.dataSource = dataSource
        vc.selectedSource = self.selectedSource
        vc.initialIndexPath = initialIndexPath
        vc.maxCount = self.maxCount
        vc.dismiss = {
            selectedSource in
            self.selectedSource = selectedSource
            self.collectionView.reloadData()
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func getSelectedSortedSource() -> [MTImagePickerModel] {
        var dataSource = [MTImagePickerModel]()
        for model in self.selectedSource.sorted(by: { return $0.sortNumber < $1.sortNumber}) {
            dataSource.append(model)
        }
        return dataSource
    }
    
    //MARK: IBActions
    @IBAction func btnFinishTouch(_ sender: AnyObject) {
        let dataSource = self.getSelectedSortedSource()
        if self.source == .Photos {
            if #available(iOS 8.0, *) {
                self.delegate?.imagePickerController?(picker:self.navigation, didFinishPickingWithPhotosModels: dataSource as! [MTImagePickerPhotosModel])
            } else {
                // Fallback on earlier versions
            }
        } else {
            self.delegate?.imagePickerController?(picker:self.navigation, didFinishPickingWithAssetsModels: dataSource as! [MTImagePickerAssetsModel])
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnPreviewTouch(_ sender: AnyObject) {
        let dataSource = self.getSelectedSortedSource()
        self.pushToImageSelectorPreviewController(initialIndexPath: nil, dataSource: dataSource)
    }
    @IBAction func btnCancelTouch(_ sender: AnyObject) {
        self.delegate?.imagePickerControllerDidCancel?(picker: self.navigation)
        self.dismiss(animated: true, completion: nil)
    }
}

class MTImagePickerCollectionView:UICollectionView {
    @IBOutlet weak var trailing: NSLayoutConstraint!
    @IBOutlet weak var leading: NSLayoutConstraint!
    var prevItemSize:CGSize?
    var prevOffset:CGFloat = 0
}
