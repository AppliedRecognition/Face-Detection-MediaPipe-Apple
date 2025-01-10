//
//  FaceDetectionMediaPipe.swift
//  FaceDetectionMediaPipe
//
//  Created by Jakub Dolejs on 07/03/2024.
//

import Foundation
import MediaPipeTasksVision
import VerIDCommonTypes

public class FaceDetectionMediaPipe: FaceDetection {
    
    private let faceDetector: FaceDetector
    
    public init() throws {
        guard let modelPath = Bundle.module.path(forResource: "blaze_face_short_range", ofType: "tflite") else {
            throw FaceDetectionError.modelFileNotFound
        }
        let options = FaceDetectorOptions()
        options.baseOptions.modelAssetPath = modelPath
        options.runningMode = .image
        self.faceDetector = try FaceDetector(options: options)
    }
    
    public func detectFacesInImage(_ image: Image, limit: Int) throws -> [Face] {
//        let cgImage = try image.convertToCGImage()
        let mpImage = try MPImage(pixelBuffer: image.videoBuffer)
//        let mpImage = try MPImage(uiImage: UIImage(cgImage: cgImage))
        let result = try self.faceDetector.detect(image: mpImage)
        let transform = CGAffineTransform(scaleX: CGFloat(image.width), y: CGFloat(image.height))
        if result.detections.isEmpty {
            return []
        }
        return Array(result.detections.map { detection in
            let keypoints = detection.keypoints?.map({ NormalizedKeypoint(location: $0.location.applying(transform), label: $0.label, score: $0.score)}) ?? []
            let angle = self.angleFromKeypoints(keypoints)
            return Face(
                bounds: detection.boundingBox,
                angle: angle,
                quality: detection.categories.first?.score ?? 10,
                landmarks: keypoints.map({ $0.location }),
                leftEye: keypoints[0].location,
                rightEye: keypoints[1].location,
                noseTip: keypoints[2].location,
                mouthCentre: keypoints[3].location
            )
        }.sorted(by: <)[0..<min(result.detections.count, limit)])
    }
    
    private func angleFromKeypoints(_ keypoints: [NormalizedKeypoint]) -> EulerAngle<Float> {
        let leftEye = keypoints[0].location
        let rightEye = keypoints[1].location
        let noseTip = keypoints[2].location
        let leftEarTragion = keypoints[4].location
        let rightEarTragion = keypoints[5].location
        return FaceAngleCalculator.calculateFaceAngle(leftEye: leftEye, rightEye: rightEye, noseTip: noseTip, leftEarTragion: leftEarTragion, rightEarTragion: rightEarTragion)
    }
}
