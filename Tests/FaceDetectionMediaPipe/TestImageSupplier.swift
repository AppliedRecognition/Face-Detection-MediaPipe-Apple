//
//  TestImageSupplier.swift
//  FaceDetectionMediaPipeTests
//
//  Created by Jakub Dolejs on 28/06/2024.
//

import Foundation
import UIKit
import VerIDCommonTypes

class TestImageSupplier {
    
    let baseURL: URL = URL(string: "https://ver-id.s3.amazonaws.com/test_images/poses_01/")!
    
    func loadImageForBearing(_ bearing: Bearing) -> UIImage? {
        let imageNames: [Bearing: String] = [
            .straight: "straight.jpg",
            .left: "left.jpg",
            .right: "right.jpg",
            .up: "up.jpg",
            .down: "down.jpg",
            .leftUp: "up_left.jpg",
            .rightUp: "up_right.jpg"
        ]
        if let imageName = imageNames[bearing] {
            let url = self.baseURL.appendingPathComponent(imageName)
            let name = url.lastPathComponent
            guard let cacheURL = (try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true))?.appendingPathComponent(name) else {
                return nil
            }
            let imageData: Data
            if !FileManager.default.fileExists(atPath: cacheURL.path), let data = try? Data(contentsOf: url) {
                try? data.write(to: cacheURL)
                imageData = data
            } else if let data = try? Data(contentsOf: cacheURL) {
                imageData = data
            } else {
                return nil
            }
            return UIImage(data: imageData)
        }
        return nil
    }
}
