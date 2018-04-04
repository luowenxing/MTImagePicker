
//
//  ImageSelectorPreviewController.swift
//  CMBMobile
//
//  Created by Luo on 5/11/16.
//  Copyright © 2016 Yst－WHB. All rights reserved.
//
import UIKit
import AVFoundation

class MTImagePickerPreviewController:UIViewController,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    
    weak var delegate:MTImagePickerDataSourceDelegate!
    var dataSource:[MTImagePickerModel]!
    var initialIndexPath:IndexPath?
    
    @IBOutlet weak var lbIndex: UILabel!
    @IBOutlet weak var collectionView: MTImagePickerCollectionView!
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var lbSelected: UILabel!
    
    @IBOutlet var topViews: [UIView]!
    @IBOutlet var bottomViews: [UIView]!
    
    private var initialScrollDone = false
    
    class var instance:MTImagePickerPreviewController {
        get {
            let storyboard = UIStoryboard(name: "MTImagePicker", bundle: Bundle.getResourcesBundle())
            let vc = storyboard.instantiateViewController(withIdentifier: "MTImagePickerPreviewController") as! MTImagePickerPreviewController
            return vc
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbSelected.text = String(delegate.selectedSource.count)
        self.lbIndex.text = "\(initialIndexPath?.row ?? 0 + 1)/\(dataSource.count)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.scrollViewDidEndDecelerating(self.collectionView)
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !self.initialScrollDone {
            self.initialScrollDone = true
            if let initialIndexPath = self.initialIndexPath {
                self.collectionView.scrollToItem(at: initialIndexPath, at: .right, animated: false)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = self.dataSource[indexPath.row]
        if model.mediaType == .Photo {
            let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath as IndexPath) as! ImagePickerPreviewCell
            cell.layer.shouldRasterize = true
            cell.layer.rasterizationScale = UIScreen.main.scale
            cell.initWithModel(model, controller: self)
            return cell
        } else {
            let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath as IndexPath) as! VideoPickerPreviewCell
            cell.layer.shouldRasterize = true
            cell.layer.rasterizationScale = UIScreen.main.scale
            cell.initWithModel(model: model,controller:self)
            return cell
        } 
    }
    
    // 旋转处理
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        if self.interfaceOrientation.isPortrait != toInterfaceOrientation.isPortrait {
            if let videoCell = self.collectionView.visibleCells.first as? VideoPickerPreviewCell {
                // CALayer 无法autolayout 需要重设frame
                videoCell.resetLayer(frame: UIScreen.main.compatibleBounds)
            }
            self.collectionView.prevItemSize = (self.collectionView.collectionViewLayout as! MTImagePickerPreviewFlowLayout).itemSize
            self.collectionView.prevOffset = self.collectionView.contentOffset.x
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.bounds.width, height: self.collectionView.bounds.height)
    }
    
    //MARK:UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let videoCell = self.collectionView.visibleCells.first as? VideoPickerPreviewCell {
            videoCell.didScroll()
        }
    }
    
    //防止visibleCells出现两个而不是一个，导致.first得到的是未显示的cell
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.perform(#selector(MTImagePickerPreviewController.didEndDecelerating), with: nil, afterDelay: 0)
    }
    
    @objc func didEndDecelerating() {
        let cell = self.collectionView.visibleCells.first
        if let videoCell = cell as? VideoPickerPreviewCell {
            videoCell.didEndScroll()
        } else if let imageCell = cell as? ImagePickerPreviewCell {
            imageCell.didEndScroll()
        }
        if let index = self.collectionView.indexPathsForVisibleItems.first {
            self.lbIndex.text = "\(index.row + 1)/\(dataSource.count)"
            let model = self.dataSource[index.row]
            self.btnCheck.isSelected = delegate.selectedSource.contains(model)
        }
    }
    
    @IBAction func btnBackTouch(_ sender: AnyObject) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCheckTouch(_ sender: UIButton) {
        if delegate.selectedSource.count < delegate.maxCount || sender.isSelected == true {
            sender.isSelected = !sender.isSelected
            if let indexPath = self.collectionView.indexPathsForVisibleItems.first {
                let model = self.dataSource[indexPath.row]
                if sender.isSelected {
                    delegate.selectedSource.append(model)
                    sender.heartbeatsAnimation(duration: 0.15)
                }else {
                    if let removeIndex = delegate.selectedSource.index(of: self.dataSource[indexPath.row]) {
                        delegate.selectedSource.remove(at: removeIndex)
                    }
                }
                self.lbSelected.text = String(delegate.selectedSource.count)
                self.lbSelected.heartbeatsAnimation(duration: 0.15)
            }
        } else {
            let alertView = FlashAlertView(message: "Maxium selected".localized, delegate: nil)
            alertView.show()
        }
    }
}

