#
# Be sure to run `pod lib lint baseapp-ios-core-v1.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#cd 

Pod::Spec.new do |s|
  s.name             = 'baseapp-ios-core-v1'
  s.version          = '0.5.5'
  s.summary          = 'A short description of baseapp-ios-core-v1.'
  s.description      = s.summary
  s.homepage         = 'https://bitbucket.org/silverlogic/baseapp-ios-core-v1'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'patsluth' => 'ps@tsl.io' }
  s.source           = { :git => 'https://bitbucket.org/silverlogic/baseapp-ios-core-v1', :tag => s.version.to_s }
  
  s.swift_version = '5.1'
  s.requires_arc = true
  s.static_framework = true

  s.ios.deployment_target = '16.0'
  s.osx.deployment_target = '13.0'
  s.watchos.deployment_target = '9.0'
  
  s.default_subspecs = 'Default'
  
  
  s.subspec 'Default' do |ss|
      ss.ios.dependency 'RxSwift', '~> 6.9.0'
      ss.ios.dependency 'RxCocoa', '~> 6.9.0'
      ss.ios.dependency 'RxSwiftExt', '~> 6.2.1'
      ss.ios.dependency 'PromiseKit', '~> 6.18.1'
      ss.ios.dependency 'CancelForPromiseKit', '~> 1.1.0'
#      ss.ios.dependency 'CancellablePromiseKit'
      ss.ios.dependency 'Alamofire', '~> 4.9.1'
      ss.ios.dependency 'CancelForPromiseKit/Alamofire'
      ss.ios.dependency 'Kingfisher', '~> 8.6.2'
      ss.ios.dependency 'SwiftyBeaver', '~> 2.1.1'
      ss.ios.dependency 'R.swift', '~> 7.8.0'
      ss.ios.dependency 'Alertift', '~> 4.2.0'
      ss.ios.dependency 'DeviceKit'
      ss.ios.dependency 'SnapKit', '~> 5.7.1'
      ss.ios.dependency 'SwiftDate', '~> 7.0.0'
      ss.ios.dependency 'CoreStore', '~> 9.3.0'
      
      ss.watchos.dependency 'RxSwift', '~> 6.9.0'
      ss.watchos.dependency 'RxCocoa', '~> 6.9.0'
      ss.watchos.dependency 'RxSwiftExt', '~> 6.2.1'
      ss.watchos.dependency 'PromiseKit', '~> 6.18.1'
      ss.watchos.dependency 'CancelForPromiseKit', '~> 1.1.0'
      ss.watchos.dependency 'SwiftyBeaver', '~> 2.1.1'
      ss.watchos.dependency 'SwiftDate', '~> 7.0.0'
      
      ss.ios.frameworks = 'Foundation',
      'CoreFoundation',
      'CoreGraphics',
      'CoreImage',
      'CoreLocation',
      'CoreData',
      'UIKit',
      'SystemConfiguration',
      'AVKit',
      'AVFoundation'
      ss.osx.frameworks = 'Foundation',
      'CoreFoundation',
      'CoreGraphics',
      'CoreImage',
      'CoreLocation',
      'CoreData',
      'SystemConfiguration'
      ss.watchos.frameworks = 'Foundation',
      'CoreFoundation',
      'CoreGraphics',
      'AVKit',
      'AVFoundation'
      
      ss.ios.source_files = 'baseapp-ios-core-v1/src/Default/Classes/**/*'
      ss.osx.source_files = 'baseapp-ios-core-v1/src/Default/Classes/**/*'
      ss.watchos.source_files = 'baseapp-ios-core-v1/src/Default/Classes/**/*'
      ss.watchos.exclude_files = 'baseapp-ios-core-v1/src/Default/Classes/AVKit/**/*',
      'baseapp-ios-core-v1/src/Default/Classes/CoreLocation/**/*',
      'baseapp-ios-core-v1/src/Default/Classes/CoreData/**/*',
      'baseapp-ios-core-v1/src/Default/Classes/CoreImage/**/*',
      'baseapp-ios-core-v1/src/Default/Classes/MapKit/**/*',
      'baseapp-ios-core-v1/src/Default/Classes/R.Swift/**/*'
      
      ss.ios.resource = 'baseapp-ios-core-v1/src/Default/Resources/**/*'
      ss.osx.resource = 'baseapp-ios-core-v1/src/Default/Resources/**/*'
  end
  
  s.subspec 'simd' do |ss|
      ss.dependency 'baseapp-ios-core-v1/Default'
      
      ss.frameworks = 'Foundation',
      'CoreFoundation'
      
      ss.ios.source_files = 'baseapp-ios-core-v1/src/simd/Classes/**/*'
      ss.ios.resource = 'baseapp-ios-core-v1/src/simd/Resources/**/*'
  end
  
  s.subspec 'SceneKit' do |ss|
      ss.dependency 'baseapp-ios-core-v1/Default'
      ss.dependency 'baseapp-ios-core-v1/simd'
      
      ss.frameworks = 'Foundation',
      'CoreFoundation',
      'SceneKit'
      
      ss.ios.source_files = 'baseapp-ios-core-v1/src/SceneKit/Classes/**/*'
      ss.ios.resource = 'baseapp-ios-core-v1/src/SceneKit/Resources/**/*'
  end
  
  s.subspec 'ARKit' do |ss|
      ss.dependency 'baseapp-ios-core-v1/Default'
      ss.dependency 'baseapp-ios-core-v1/SceneKit'
      ss.dependency 'baseapp-ios-core-v1/simd'
      
      ss.frameworks = 'Foundation',
      'CoreFoundation',
      'ARKit'
      
      ss.ios.source_files = 'baseapp-ios-core-v1/src/ARKit/Classes/**/*'
      ss.ios.resource = 'baseapp-ios-core-v1/src/ARKit/Resources/**/*'
  end
  
  s.subspec 'FilePreviewer' do |ss|
      ss.dependency 'baseapp-ios-core-v1/Default'
      
      ss.ios.frameworks = 'Foundation', 'UIKit', 'QuickLook', 'PDFKit', 'AVKit'
      
      ss.ios.source_files = 'baseapp-ios-core-v1/src/FilePreviewer/Classes/**/*'
#      ss.ios.resource = 'baseapp-ios-core-v1/src/FilePreviewer/Resources/**/*'
      ss.ios.resource_bundles = {
          'FilePreviewer' => ['baseapp-ios-core-v1/src/FilePreviewer/Resources/**/*']
      }
  end

end
