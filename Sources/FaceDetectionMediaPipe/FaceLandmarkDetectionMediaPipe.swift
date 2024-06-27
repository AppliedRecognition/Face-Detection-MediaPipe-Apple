//
//  FaceLandmarkDetectionMediaPipe.swift
//  FaceDetectionMediaPipe
//
//  Created by Jakub Dolejs on 19/06/2024.
//

import Foundation
import MediaPipeTasksVision
import VerIDCommonTypes

public class FaceLandmarkDetectionMediaPipe: FaceDetection {
    
    private let faceLandmarker: FaceLandmarker
    
    public init() throws {
        guard let modelPath = Bundle.module.path(forResource: "face_landmarker", ofType: "task") else {
            throw FaceDetectionError.modelFileNotFound
        }
        let options = FaceLandmarkerOptions()
        options.baseOptions.modelAssetPath = modelPath
        options.outputFaceBlendshapes = false
        options.outputFacialTransformationMatrixes = false
        options.runningMode = .image
        self.faceLandmarker = try FaceLandmarker(options: options)
    }
    
    public func detectFacesInImage(_ image: Image, limit: Int) throws -> [Face] {
        let cgImage = try image.convertToCGImage()
        let mpImage = try MPImage(uiImage: UIImage(cgImage: cgImage))
        let result = try self.faceLandmarker.detect(image: mpImage)
        let faces: [Face] = result.faceLandmarks.map {
            let faceLandmarks = $0.map { landmark in CGPoint(x: CGFloat(image.width) * CGFloat(landmark.x), y: CGFloat(image.height) * CGFloat(landmark.y)) }
//            let leftEye = faceLandmarks[468]
//            let rightEye = faceLandmarks[473]
            var topLeft: CGPoint?
            var bottomRight: CGPoint?
            for landmark in faceLandmarks {
                if var tl = topLeft {
                    if landmark.x < tl.x {
                        tl.x = landmark.x
                    }
                    if landmark.y < tl.y {
                        tl.y = landmark.y
                    }
                } else {
                    topLeft = landmark
                }
                if var br = bottomRight {
                    if landmark.x > br.x {
                        br.x = landmark.x
                    }
                    if landmark.y > br.y {
                        br.y = landmark.y
                    }
                } else {
                    bottomRight = landmark
                }
            }
            let width = bottomRight!.x - topLeft!.x
            let height = bottomRight!.y - topLeft!.y
            let face = Face(bounds: CGRect(x: topLeft!.x, y: topLeft!.y, width: width, height: height).insetBy(dx: 0 - width * 0.1, dy: 0 - height * 0.1), angle: self.angleFromLandmarks(faceLandmarks), quality: 10, landmarks: faceLandmarks)
            return face
        }
        let centre = CGPoint(x: image.width / 2, y: image.height / 2)
        return faces.sorted(by: { $0.bounds.centre.distance(to: centre) < $1.bounds.centre.distance(to: centre) })
    }
    
    private func angleFromLandmarks(_ landmarks: [CGPoint]) -> EulerAngle<Float> {
        let noseTip = landmarks[4]
        let leftEarTragion = landmarks[234]
        let rightEarTragion = landmarks[454]
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

fileprivate extension CGPoint {
    
    func distance(to other: CGPoint) -> CGFloat {
        return hypot(self.x - other.x, self.y - other.y)
    }
}

fileprivate extension CGRect {
    
    var centre: CGPoint {
        CGPoint(x: self.midX, y: self.midY)
    }
}
