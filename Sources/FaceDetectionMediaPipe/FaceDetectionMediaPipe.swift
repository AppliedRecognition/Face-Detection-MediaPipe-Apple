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
        let cgImage = try image.convertToCGImage()
        let mpImage = try MPImage(uiImage: UIImage(cgImage: cgImage))
        let result = try self.faceDetector.detect(image: mpImage)
        let transform = CGAffineTransform(scaleX: CGFloat(image.width), y: CGFloat(image.height))
        return Array(result.detections.map { detection in
            let keypoints = detection.keypoints?.map({ NormalizedKeypoint(location: $0.location.applying(transform), label: $0.label, score: $0.score)}) ?? []
            let angle = self.angleFromKeypoints(keypoints)
            return Face(bounds: detection.boundingBox, angle: angle, quality: detection.categories.first?.score ?? 10, landmarks: keypoints.map({ $0.location }))
        }.sorted(by: <)[0..<limit])
    }
    
    private func angleFromKeypoints(_ keypoints: [NormalizedKeypoint]) -> EulerAngle<Float> {
        guard let noseTip = keypoints.first(where: { $0.label == "noseTip" })?.location else {
            return .identity
        }
        guard let leftEarTragion = keypoints.first(where: { $0.label == "leftEarTragion" })?.location else {
            return .identity
        }
        guard let rightEarTragion = keypoints.first(where: { $0.label == "rightEarTragion" })?.location else {
            return .identity
        }
        let centreX = leftEarTragion.x + (rightEarTragion.x - leftEarTragion.x) / 2
        let x = rightEarTragion.x - leftEarTragion.x
        let y = noseTip.x - centreX
        var yaw = 180 - atan2(y, x) * (180 / .pi)
        if (yaw > 180) {
            yaw -= 360
        }
        yaw *= 1.5
        let radius = sqrt(x * x + y * y)
        let centreY = leftEarTragion.y + (rightEarTragion.y - leftEarTragion.y) / 2
        let pitch = sin((noseTip.y - centreY) / radius) * (180 / .pi) - 10
        return EulerAngle<Float>(yaw: Float(yaw), pitch: Float(pitch), roll: 0)
    }
}
