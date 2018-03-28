Pod::Spec.new do |s|
  s.name         = "MTImagePicker"

  s.version      = "3.0.2"

  s.summary      = "A WeiXin like multiple image picker for iOS7+."

  s.platform = :ios

  s.ios.deployment_target = '8.0'

  s.requires_arc = true

  s.description  =  "A WeiXin like multiple image/video picker using ALAssetsLibrary and compatible for iOS7 and higher"

  s.homepage     = "https://github.com/luowenxing/MTImagePicker"

  s.license      = "MIT"

  s.author             = { "Luo" => "511352272@qq.com" }

  s.source       = { :git => "https://github.com/luowenxing/MTImagePicker.git", :tag => "#{s.version}" }

  s.framework = "UIKit"

  s.source_files  = "MTImagePicker/MTImagePicker", "MTImagePicker/MTImagePicker/**/*.{swift}"

  s.resources = "MTImagePicker/MTImagePicker/**/*.{png,jpeg,jpg,storyboard,xib}"
end
