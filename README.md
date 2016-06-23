# MTImagePicker
A WeiXin like multiple image/video picker using `ALAssetsLibrary` and compatible for iOS7 and higher

#Demo
![demo](https://github.com/luowenxing/MTImagePicker/blob/master/MTImagePicker/Demo/demo.gif)

# Requirement
* iOS7.0+
* Build success in Xcode 7.3 Swift 2.2

# Installation
* There is no ohter dependency in `MTImagePicker`.Recommanded Simply drag the `MTImagePicker/MTImagePicker` folder to your project.
* MTImagePicker is also available through CocoaPods. However using CocoaPod in Swift project required dynamic framework therefore iOS8.0+ is needed.To install it, simply add the following line to your Podfile:
```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!
pod 'MTImagePicker', '~> 1.0.1'
```

#Usage
The MTImagePicker is similiar to `UIImagePickerController`.It's easy to use the image picker following the sample code in demo like below
```
let imagePicker = MTImagePickerController.instance
imagePicker.mediaTypes = [MTImagePickerMediaType.Photo,MTImagePickerMediaType.Video]
imagePicker.delegate = self
imagePicker.maxCount = 10
let nc = UINavigationController(rootViewController: imagePicker)
self.presentViewController(nc, animated: true, completion: nil)
```
Implement the delegate method
```
@objc protocol MTImagePickerControllerDelegate:NSObjectProtocol {
    optional func imagePickerController(picker:MTImagePickerController, didFinishPickingWithModels models:[MTImagePickerModel])
    optional func imagePickerControllerDidCancel(picker: MTImagePickerController)
}
```

