//
//  FaviconFinderTests.swift
//  FaviconFinderTests
//
//  Created by William Lumley on 16/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

import XCTest

@testable import FaviconFinder

class FaviconFinderTests: XCTestCase {

    let googleUrl = URL(string: "https://google.com")!
    let appleUrl  = URL(string: "https://apple.com")!
    let realFaviconGeneratorUrl = URL(string: "https://realfavicongenerator.net/blog/apple-touch-icon-the-good-the-bad-the-ugly/")!
    let webApplicationManifestUrl = URL(string: "https://googlechrome.github.io/samples/web-application-manifest/")!

    override func setUp() {

    }

    override func tearDown() {

    }

    func testFaviconIcoFind() {
        let expectation = self.expectation(description: "Favicon.ico FaviconFind")

        FaviconFinder(
            url: self.googleUrl,
            preferredType: .ico,
            preferences: [:],
            logEnabled: true
        ).downloadFavicon { result in
            switch result {
            case .success(let favicon):
                // Ensure that our favicon is actually valid
                XCTAssertTrue(favicon.image.isValidImage)

                // Ensure that our favicon was retrieved from the desired source
                XCTAssertTrue(favicon.downloadType == .ico)
                
                // Let the test know that we got our favicon back
                expectation.fulfill()

            case .failure(let error):
                XCTAssert(false, "Failed to download favicon.ico file: \(error)")
            }
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testFaviconHtmlFind() {
        let expectation = self.expectation(description: "HTML FaviconFind")
        
        FaviconFinder(
            url: self.realFaviconGeneratorUrl,
            preferredType: .html,
            preferences: [:],
            logEnabled: true
        ).downloadFavicon { result in
            switch result {
            case .success(let favicon):
                
                // Ensure that our favicon is actually valid
                XCTAssertTrue(favicon.image.isValidImage)

                // Ensure that our favicon was retrieved from the desired source
                XCTAssertTrue(favicon.downloadType == .html)
                
                // Let the test know that we got our favicon back
                expectation.fulfill()

            case .failure(let error):
                XCTAssert(false, "Failed to download favicon from HTML header: \(error.localizedDescription)")
            }
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testFaviconWebApplicationManifestFileFind() {
        let expectation = self.expectation(description: "WebApplicationManifestFile FaviconFind")
        
        FaviconFinder(
            url: self.webApplicationManifestUrl,
            preferredType: .webApplicationManifestFile,
            preferences: [:],
            logEnabled: true
        ).downloadFavicon { result in
            switch result {
            case .success(let favicon):
                
                // Ensure that our favicon is actually valid
                XCTAssertTrue(favicon.image.isValidImage)

                // Ensure that our favicon was retrieved from the desired source
                XCTAssertTrue(favicon.downloadType == .webApplicationManifestFile)
                
                // Let the test know that we got our favicon back
                expectation.fulfill()

            case .failure(let error):
                XCTAssert(false, "Failed to download favicon from WebApplicationManifestFile header: \(error.localizedDescription)")
            }
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
}

private extension FaviconImage {

    var isValidImage: Bool {
        #if targetEnvironment(macCatalyst)
        return self.isValid

        #elseif canImport(AppKit)
        return self.isValid

        #elseif canImport(UIKit)
        return self.isValid

        #endif
    }

}
