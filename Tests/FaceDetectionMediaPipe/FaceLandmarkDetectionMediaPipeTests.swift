//
//  FaceLandmarkDetectionMediaPipeTests.swift
//  FaceDetectionMediaPipeTests
//
//  Created by Jakub Dolejs on 19/06/2024.
//

import XCTest
import VerIDCommonTypes
import UniformTypeIdentifiers
@testable import FaceDetectionMediaPipe

final class FaceLandmarkDetectionMediaPipeTests: XCTestCase {
    
    var landmarkDetector: FaceLandmarkDetectionMediaPipe!
    let testImageSupplier = TestImageSupplier()

    override func setUpWithError() throws {
        self.landmarkDetector = try FaceLandmarkDetectionMediaPipe()
    }

    func test_detectFaceInImage() throws {
        try self.testImageURLs.forEach({ url in
            let imageData = try Data(contentsOf: url)
            guard let uiImage = UIImage(data: imageData), let cgImage = uiImage.cgImage, let image = Image(cgImage: cgImage) else {
                XCTFail()
                return
            }
            let faces = try self.landmarkDetector.detectFacesInImage(image, limit: 1)
            XCTAssertEqual(faces.count, 1)
        })
    }
    
    func test_faceDetectionSpeed() throws {
        try self.testImageURLs.forEach({ url in
            let imageData = try Data(contentsOf: url)
            guard let uiImage = UIImage(data: imageData), let cgImage = uiImage.cgImage, let image = Image(cgImage: cgImage) else {
                XCTFail()
                return
            }
            measure {
                do {
                    _ = try self.landmarkDetector.detectFacesInImage(image, limit: 1)
                } catch {
                    XCTFail()
                }
            }
        })
    }
    
    @available(iOS 14.0, *)
    func test_attachImagesWithFaces() throws {
        try self.testImageURLs.forEach { url in
            let imageData = try Data(contentsOf: url)
            guard let uiImage = UIImage(data: imageData), let cgImage = uiImage.cgImage, let image = Image(cgImage: cgImage) else {
                XCTFail()
                return
            }
            if let face = try self.landmarkDetector.detectFacesInImage(image, limit: 1).first {
                let faceJson = try JSONEncoder().encode(face)
                let faceAttachment = XCTAttachment(data: faceJson, uniformTypeIdentifier: UTType.json.identifier)
                faceAttachment.lifetime = .keepAlways
                faceAttachment.name = url.lastPathComponent
                self.add(faceAttachment)
            }
        }
    }
    
    func test_detectFaceInImageWithBearing() throws {
        let bearings: [Bearing] = [.straight, .left, .right, .up, .down, .leftUp, .rightUp]
        try bearings.forEach({ bearing in
            guard let uiImage = self.testImageSupplier.loadImageForBearing(bearing) else {
                XCTFail()
                return
            }
            guard let cgImage = uiImage.cgImage, let image = Image(cgImage: cgImage) else {
                XCTFail()
                return
            }
            let faces = try self.landmarkDetector.detectFacesInImage(image, limit: 1)
            XCTAssertEqual(faces.count, 1)
            NSLog("\(bearing): yaw %.0f, pitch %.0f, roll %.0f", faces[0].angle.yaw, faces[0].angle.pitch, faces[0].angle.roll)
        })
    }
    
    private lazy var testImageURLs: [URL] = {
        Bundle(for: type(of: self)).urls(forResourcesWithExtension: "jpg", subdirectory: "Resources") ?? []
    }()

}
