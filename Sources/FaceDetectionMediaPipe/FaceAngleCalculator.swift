//
//  FaceAngleCalculator.swift
//  FaceDetectionMediaPipe
//
//  Created by Jakub Dolejs on 28/06/2024.
//

import Foundation
import VerIDCommonTypes

class FaceAngleCalculator {
    
    static func calculateFaceAngle(leftEye: CGPoint, rightEye: CGPoint, noseTip: CGPoint, leftEarTragion: CGPoint, rightEarTragion: CGPoint) -> EulerAngle<Float> {
        let centreX: Float = leftEarTragion.x.asFloat + (rightEarTragion.x.asFloat - leftEarTragion.x.asFloat) / 2
        let x: Float = rightEarTragion.x.asFloat - leftEarTragion.x.asFloat
        let y: Float = noseTip.x.asFloat - centreX
        let yaw: Float = atan2(y, x).degrees * 1.5
        let radius: Float = sqrt(x * x + y * y);
        let centreY: Float = leftEarTragion.y.asFloat + (rightEarTragion.y.asFloat - leftEarTragion.y.asFloat) / 2
        let pitch: Float = sin((noseTip.y.asFloat - centreY) / radius).degrees - 10
        let deltaY = rightEye.y.asFloat - leftEye.y.asFloat
        let deltaX = rightEye.x.asFloat - leftEye.x.asFloat
        let roll: Float = atan2(deltaY, deltaX).degrees
        return EulerAngle(yaw: yaw, pitch: pitch, roll: roll)
    }
}

fileprivate extension CGFloat {
    
    var asFloat: Float {
        return Float(self)
    }
}

fileprivate extension Float {
    
    var degrees: Float {
        return self * 180 / .pi
    }
}
