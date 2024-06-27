//
//  FaceLandmarkDetectionMediaPipeTests.swift
//  FaceDetectionMediaPipeTests
//
//  Created by Jakub Dolejs on 19/06/2024.
//

import XCTest
@testable import FaceDetectionMediaPipe

final class FaceLandmarkDetectionMediaPipeTests: XCTestCase {
    
    var landmarkDetector: FaceLandmarkDetectionMediaPipe!

    override func setUpWithError() throws {
        self.landmarkDetector = try FaceLandmarkDetectionMediaPipe()
    }

    func test_detectFaceInImage() throws {
        try self.testImageURLs.forEach({ url in
            let imageData = try Data(contentsOf: url)
            guard let image = UIImage(data: imageData) else {
                XCTFail()
                return
            }
            let faces = try self.landmarkDetector.detectFacesInImage(image.convertToImage(), limit: 1)
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
                    _ = try self.landmarkDetector.detectFacesInImage(verIDImage, limit: 1)
                } catch {
                    XCTFail()
                }
            }
        })
    }
    
    private lazy var testImageURLs: [URL] = {
        Bundle(for: type(of: self)).urls(forResourcesWithExtension: "jpg", subdirectory: "test-images") ?? []
    }()

}
