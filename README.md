# MTImagePicker
A WeiXin like multiple image/video picker using `ALAssetsLibrary` and compatible for iOS7 and higher

#Demo
![demo](https://github.com/luowenxing/MTImagePicker/blob/master/MTImagePicker/Demo/demo.gif)

# Installation
* There is no ohter dependency in `MTImagePicker`.Simply drag the `MTImagePicker/MTImagePicker` folder to your project.

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

