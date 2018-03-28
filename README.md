# MTImagePicker
A WeiXin like multiple image and video picker which is compatible for iOS7+.You can use  either `ALAssetsLibrary` or `Photos framework` by setting the source of `MTImagePickerController`.

# Demo
![demo](https://github.com/luowenxing/MTImagePicker/blob/master/MTImagePicker/Demo/demo.gif)

# Requirement
* iOS7.0+
* Build success in Xcode 9.2 Swift 4.0

# Installation
* There is no ohter dependency in `MTImagePicker`.Recommanded Simply drag the `MTImagePicker/MTImagePicker` folder to your project.
* MTImagePicker is also available through CocoaPods. However using CocoaPod in Swift project required dynamic framework therefore iOS8.0+ is needed.To install it, simply add the following line to your Podfile:
```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!
pod 'MTImagePicker', '~> 3.0.2'
```

# Usage
* The MTImagePicker is similiar to `UIImagePickerController`.It's easy to use the image picker following the sample code in demo like below
```
let imagePicker = MTImagePickerController.instance
imagePicker.mediaTypes = [MTImagePickerMediaType.Photo,MTImagePickerMediaType.Video]
imagePicker.imagePickerDelegate = self
imagePicker.maxCount = 10 // max select count
imagePicker.defaultShowCameraRoll = true // when set to true would show Camera Roll Album like WeChat by default. 
```
* You can use  either `ALAssetsLibrary` or `Photos framework` by setting the source of `MTImagePickerController`
```
//default is MTImagePickerSource.ALAsset
imagePicker.source = MTImagePickerSource.ALAsset
//imagePicker.source = MTImagePickerSource.Photos (Work on iOS8+)
```
* Call `presentViewController` 
```
self.presentViewController(imagePicker, animated: true, completion: nil)
```
* Implement the delegate method accordding to the `source`.
```
@objc protocol MTImagePickerControllerDelegate:NSObjectProtocol {

    // Implement it when setting source to MTImagePickerSource.ALAsset
    optional func imagePickerController(picker:MTImagePickerController, didFinishPickingWithAssetsModels models:[MTImagePickerAssetsModel])
    
    // Implement it when setting source to MTImagePickerSource.Photos
    @available(iOS 8.0, *)
    optional func imagePickerController(picker:MTImagePickerController, didFinishPickingWithPhotosModels models:[MTImagePickerPhotosModel])
    
    optional func imagePickerControllerDidCancel(picker: MTImagePickerController)
}
```

# TODO
* ~~Add Albums selecting support.~~ Done.
