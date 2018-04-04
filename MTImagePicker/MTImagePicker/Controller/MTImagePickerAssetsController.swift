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
    
    weak var delegate:MTImagePickerDataSourceDelegate!
    var groupModel:MTImagePickerAlbumModel!
    
    @IBOutlet weak var collectionView: MTImagePickerCollectionView!
    @IBOutlet weak var lbSelected: UILabel!
    @IBOutlet weak var btnPreview: UIButton!
    
    private var dataSource = [MTImagePickerModel]()
    private var initialScrollDone:Bool = false
    
    class var instance:MTImagePickerAssetsController {
        get {
            let storyboard = UIStoryboard(name: "MTImagePicker", bundle: Bundle.getResourcesBundle())
            let vc = storyboard.instantiateViewController(withIdentifier: "MTImagePickerController") as! MTImagePickerAssetsController
            return vc
        }
    }
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let title = self.groupModel.getAlbumName() {
            self.title = title
        }
        let loading = LoadingViewController()
        loading.show(text: "Loading...".localized)
        self.groupModel?.getMTImagePickerModelsListAsync { (models) in
            loading.dismiss()
            self.dataSource = models
            self.collectionView.reloadData()
            self.scrollToBottom()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
        self.lbSelected.text = String(delegate.selectedSource.count)
        self.btnPreview.isEnabled = !(delegate.selectedSource.count == 0)
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
        cell.btnCheck.isSelected = delegate.selectedSource.contains(model)
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
        if delegate.selectedSource.count < delegate.maxCount || sender.isSelected == true {
            sender.isSelected = !sender.isSelected
            let index = (sender.superview?.superview as! MTImagePickerCell).indexPath.row
            if sender.isSelected {
               delegate.selectedSource.append(self.dataSource[index])
                sender.heartbeatsAnimation(duration: 0.15)
            }else {
                if let removeIndex = delegate.selectedSource.index(of: self.dataSource[index]) {
                    delegate.selectedSource.remove(at: removeIndex)
                }
            }
            self.lbSelected.text = String(delegate.selectedSource.count)
            self.lbSelected.heartbeatsAnimation(duration: 0.15)
            self.btnPreview.isEnabled = !(delegate.selectedSource.count == 0)
        } else {
            let alertView = FlashAlertView(message: "Maxium selected".localized, delegate: nil)
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
    
    private func pushToImageSelectorPreviewController(initialIndexPath:IndexPath?,dataSource:[MTImagePickerModel]) {
        let vc = MTImagePickerPreviewController.instance
        vc.dataSource = dataSource
        vc.delegate = self.delegate
        vc.initialIndexPath = initialIndexPath
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: IBActions
    @IBAction func btnFinishTouch(_ sender: AnyObject) {
        delegate.didFinishPicking()
    }
    
    @IBAction func btnPreviewTouch(_ sender: AnyObject) {
        let dataSource = delegate.selectedSource
        self.pushToImageSelectorPreviewController(initialIndexPath: nil, dataSource: dataSource)
    }
    @IBAction func btnCancelTouch(_ sender: AnyObject) {
        delegate.didCancel()
    }
}

class MTImagePickerCollectionView:UICollectionView {
    @IBOutlet weak var trailing: NSLayoutConstraint!
    @IBOutlet weak var leading: NSLayoutConstraint!
    var prevItemSize:CGSize?
    var prevOffset:CGFloat = 0
}
