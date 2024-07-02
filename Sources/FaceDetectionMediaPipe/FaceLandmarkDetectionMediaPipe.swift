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
            let minX: CGFloat = faceLandmarks.map { $0.x }.min()!
            let minY: CGFloat = faceLandmarks.map { $0.y }.min()!
            let maxX: CGFloat = faceLandmarks.map { $0.x }.max()!
            let maxY: CGFloat = faceLandmarks.map { $0.y}.max()!
            let width = maxX - minX
            let height = maxY - minY
            let face = Face(bounds: CGRect(x: minX, y: minY, width: width, height: height).insetBy(dx: 0 - width * 0.1, dy: 0 - height * 0.1), angle: self.angleFromLandmarks(faceLandmarks), quality: 10, landmarks: faceLandmarks)
            return face
        }
        if faces.isEmpty {
            return []
        }
        let centre = CGPoint(x: image.width / 2, y: image.height / 2)
        return Array(faces.sorted(by: { $0.bounds.centre.distance(to: centre) < $1.bounds.centre.distance(to: centre) })[0..<min(faces.count, limit)])
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
