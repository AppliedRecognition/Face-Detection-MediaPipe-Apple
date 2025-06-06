source 'https://github.com/AppliedRecognition/Ver-ID-CocoaPods-Repo.git'
source 'https://github.com/CocoaPods/Specs.git'

# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'FaceDetectionMediaPipe' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks! :linkage => :static

  # Pods for FaceDetectionMediaPipe
  pod 'MediaPipeTasksVision', '~> 0.10'
  pod 'VerIDCommonTypes', :git => 'https://github.com/AppliedRecognition/Ver-ID-Common-Types-Apple.git', :tag => '1.2.0'
end

target 'FaceDetectionMediaPipeTests' do
  use_frameworks! :linkage => :static
  
  pod 'VerIDCommonTypes', :git => 'https://github.com/AppliedRecognition/Ver-ID-Common-Types-Apple.git', :tag => '1.2.0'
end
