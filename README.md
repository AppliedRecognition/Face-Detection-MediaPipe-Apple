# MediaPipe face detection for iOS

Face detection library that implements Ver-ID [FaceDetection](https://github.com/AppliedRecognition/Ver-ID-Common-Types-Apple/blob/main/Sources/VerIDCommonTypes/FaceDetection.swift) protocol, making it available for use in Ver-ID [face capture](https://github.com/AppliedRecognition/Face-Capture-Apple) sessions.

The library uses [MediaPipe face detection](https://ai.google.dev/edge/mediapipe/solutions/vision/face_detector) and [MediaPipe face landmark detection](https://ai.google.dev/edge/mediapipe/solutions/vision/face_landmarker).

## Installation

The library is distributed as a CocoaPods pod. To include the library in your Podfile:

1. Add `source 'https://github.com/AppliedRecognition/Ver-ID-CocoaPods-Repo.git'` at the top of the file. Unless already included, also add `source 'https://github.com/CocoaPods/Specs.git'` after the previous source declaration.
2. Add the dependency: `'FaceDetectionMediaPipe', '~> 1.0.0'`.
3. Run `pod install`.
4. Open the generated xcworkspace file.

## Usage

The library is most useful in the context of the [Ver-ID face capture SDK](https://github.com/AppliedRecognition/Face-Capture-Apple) but it can be used on its own to detect faces in images.

### Example

```swift
import UIKit
import VerIDCommonTypes
import FaceDetectionMediaPipe

class FaceDetector {
  let faceDetection: FaceDetection

  init(detectLandmarks: Bool = false) throws {
    self.faceDetection = detectLandmarks ? try FaceLandmarkDetectionMediaPipe() : try FaceDetectionMediaPipe()
  }
  
  func detectFaceInImage(_ cgImage: CGImage, orientation: CGImagePropertyOrientation) -> Face? {
    guard let image = Image(cgImage: cgImage, orientation: orientation) else {
      return nil
    }
    guard let faces = try? faceDetection.detectFacesInImage(image, limit: 1) else {
      return nil
    }
    return faces.first
  }
}
```
