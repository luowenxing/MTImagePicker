//
//  VideoPickerPreviewCell.swift
//  MTImagePicker
//
//  Created by Luo on 5/24/16.
//  Copyright © 2016 Luo. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPickerPreviewCell:UICollectionViewCell{
    
    weak var controller:MTImagePickerPreviewController?
    var model:MTImagePickerModel!
    var avPlayer:AVPlayer!
    private var playerLayer:AVPlayerLayer!
    private var observer:AnyObject?
    
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var avPlayerView: UIView!
    
    override func awakeFromNib() {
        self.avPlayer = AVPlayer()
        self.playerLayer = AVPlayerLayer()
        self.playerLayer.player = self.avPlayer
        self.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        self.playerLayer.frame = UIScreen.main.compatibleBounds
        self.avPlayerView.layer.insertSublayer(self.playerLayer, at: 0)
        
        let singTapGesture = UITapGestureRecognizer(target: self, action: #selector(VideoPickerPreviewCell.onVideoSingleTap(_:)))
        singTapGesture.numberOfTapsRequired = 1
        singTapGesture.numberOfTouchesRequired = 1
        self.addGestureRecognizer(singTapGesture)
    }
    
    override func prepareForReuse() {
        self.imageView.isHidden = false
        self.avPlayerView.isHidden = true
        self.btnPlay.isHidden = false
    }
    
    func initWithModel(model:MTImagePickerModel,controller:MTImagePickerPreviewController) {
        self.controller = controller
        self.model = model
        self.imageView.image = model.getPreviewImage()
    }
    
    //解决滚动卡顿，在滚动结束时替换AVPlayerItem
    func didScroll() {
        if let observer = self.observer {
            self.avPlayer.pause()
            self.avPlayer.removeTimeObserver(observer)
            self.observer = nil
            self.btnPlay.isHidden = false
            self.imageView.isHidden = false
            self.setTopAndBottomView(hidden: false)
        }
        self.setTopAndBottomView(hidden: false)
    }
    
    func resetLayer() {
        self.playerLayer.frame = UIScreen.main.compatibleBounds
    }
    
    func didEndScroll() {
        self.setTopAndBottomView(hidden: false)
        self.model.getImageAsync(){
            image in
            self.imageView.image = image
        }
        //此处耗时,故放在滚动结束后调用
        if let playerItem = self.model.getAVPlayerItem() {
            self.avPlayer.replaceCurrentItem(with: playerItem)
            if let currentItem = self.avPlayer.currentItem {
                self.avPlayer.addBoundaryTimeObserver(forTimes: [currentItem.asset.duration as NSValue], queue: nil) {
                    [unowned self] in
                    DispatchQueue.main.async {
                        self.avPlayer.seek(to: CMTime(value: 0 , timescale: 30))
                        self.btnPlay.isHidden = false
                        self.setTopAndBottomView(hidden: false)
                    }
                }
            }
        }
    }
    
    func resetLayer(frame:CGRect) {
        self.playerLayer.frame = frame
    }
    
    @objc func onVideoSingleTap(_ sernder:UITapGestureRecognizer) {
        self.playerPlayOrPause()
    }
    
    @IBAction func btnPlayTouch(_ sender:UIButton) {
        self.playerPlayOrPause()
    }
    
    func setTopAndBottomView(hidden:Bool) {
        if let controller = self.controller {
            controller.topViews.forEach { $0.isHidden = !$0.isHidden }
            controller.bottomViews.forEach { $0.isHidden = !$0.isHidden }
        }
    }
    
    func playerPlayOrPause() {
        if self.avPlayer.status == .readyToPlay {
            self.imageView.isHidden = true
            self.avPlayerView.isHidden = false
            if self.avPlayer.rate != 1.0 {
                self.btnPlay.isHidden = true
                self.avPlayer.play()
                self.setTopAndBottomView(hidden: true)
            } else{
                self.btnPlay.isHidden = false
                self.avPlayer.pause()
                self.setTopAndBottomView(hidden: false)
            }
        }
    }
}






