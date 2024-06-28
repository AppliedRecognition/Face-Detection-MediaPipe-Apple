//
//  FaceDetectionMediaPipeTests.swift
//  FaceDetectionMediaPipeTests
//
//  Created by Jakub Dolejs on 07/03/2024.
//

import XCTest
import VerIDCommonTypes
@testable import FaceDetectionMediaPipe

final class FaceDetectionMediaPipeTests: XCTestCase {
    
    var faceDetector: FaceDetectionMediaPipe!
    let testImageSupplier = TestImageSupplier()

    override func setUpWithError() throws {
        self.faceDetector = try FaceDetectionMediaPipe()
    }
    
    func test_detectFaceInImage() throws {
        try self.testImageURLs.forEach({ url in
            let imageData = try Data(contentsOf: url)
            guard let image = UIImage(data: imageData) else {
                XCTFail()
                return
            }
            let faces = try self.faceDetector.detectFacesInImage(image.convertToImage(), limit: 1)
            XCTAssertEqual(faces.count, 1)
        })
    }
    
    func test_faceDetectionSpeed() throws {
        try self.testImageURLs.forEach({ url in
            let imageData = try Data(contentsOf: url)
            guard let image = UIImage(data: imageData) else {
                XCTFail()
                return
            }
            let verIDImage = try image.convertToImage()
            measure {
                do {
                    _ = try self.faceDetector.detectFacesInImage(verIDImage, limit: 1)
                } catch {
                    XCTFail()
                }
            }
        })
    }
    
    func test_detectFaceInImageWithBearing() throws {
        let bearings: [Bearing] = [.straight, .left, .right, .up, .down, .leftUp, .rightUp]
        try bearings.forEach({ bearing in
            guard let image = self.testImageSupplier.loadImageForBearing(bearing) else {
                XCTFail()
                return
            }
            let faces = try self.faceDetector.detectFacesInImage(image.convertToImage(), limit: 1)
            XCTAssertEqual(faces.count, 1)
            NSLog("\(bearing): yaw %.0f, pitch %.0f, roll %.0f", faces[0].angle.yaw, faces[0].angle.pitch, faces[0].angle.roll)
        })
    }

    private lazy var testImageURLs: [URL] = {
        Bundle(for: type(of: self)).urls(forResourcesWithExtension: "jpg", subdirectory: "test-images") ?? []
    }()
}
