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
        let leftEye = landmarks[468]
        let rightEye = landmarks[473]
        let leftEarTragion = landmarks[234]
        let rightEarTragion = landmarks[454]
        return FaceAngleCalculator.calculateFaceAngle(leftEye: leftEye, rightEye: rightEye, noseTip: noseTip, leftEarTragion: leftEarTragion, rightEarTragion: rightEarTragion)
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
