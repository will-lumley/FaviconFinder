//
//  FaviconFinderTests.swift
//  FaviconFinderTests
//
//  Created by William Lumley on 16/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

@testable import FaviconFinder
import XCTest

class FaviconFinderTests: XCTestCase {

    let googleUrl = URL(string: "https://google.com")!
    let appleUrl  = URL(string: "https://apple.com")!
    let w3SchoolsUrl = URL(string: "https://www.w3schools.com/")!
    let realFaviconGeneratorUrl = URL(string: "https://realfavicongenerator.net/blog/apple-touch-icon-the-good-the-bad-the-ugly/")!
    let webApplicationManifestUrl = URL(string: "https://googlechrome.github.io/samples/web-application-manifest/")!
    let metaRefreshRedirectUrl = URL(string: "https://www.sympy.org/")!
    let nonUtf8EncodedWebsite = URL(string: "http://foodmate.net")!

    override func setUp() {

    }

    override func tearDown() {

    }

    func testFaviconIcoFind() {
        let expectation = self.expectation(description: "Favicon.ico FaviconFind")

        Task {
            do {
                let favicon = try await FaviconFinder(
                    url: self.googleUrl,
                    preferredType: .ico,
                    preferences: [:],
                    logEnabled: true
                ).downloadFavicon()

                // Ensure that our favicon is actually valid
                XCTAssertTrue(favicon.image.isValidImage)

                // Ensure that our favicon was retrieved from the desired source
                XCTAssertTrue(favicon.downloadType == .ico)
                
                // Let the test know that we got our favicon back
                expectation.fulfill()
            } catch let error {
                XCTAssert(false, "Failed to download favicon.ico file: \(error)")
            }
        }

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    func testFaviconHtmlFind() async throws {
        do {
            let favicon = try await FaviconFinder(
                url: self.w3SchoolsUrl,
                preferredType: .html,
                preferences: [:],
                logEnabled: true
            ).downloadFavicon()

            // Ensure that our favicon is actually valid
            XCTAssertTrue(favicon.image.isValidImage)

            // Ensure that our favicon was retrieved from the desired source
            XCTAssertTrue(favicon.downloadType == .html)
        } catch let error {
            XCTAssert(false, "Failed to download favicon from HTML header: \(error.localizedDescription)")
        }
    }

    func testFaviconWebApplicationManifestFileFind() {
        let expectation = self.expectation(description: "WebApplicationManifestFile FaviconFind")

        Task {
            do {
                let favicon = try await FaviconFinder(
                    url: self.webApplicationManifestUrl,
                    preferredType: .webApplicationManifestFile,
                    preferences: [:],
                    logEnabled: true
                ).downloadFavicon()

                // Ensure that our favicon is actually valid
                XCTAssertTrue(favicon.image.isValidImage)

                // Ensure that our favicon was retrieved from the desired source
                XCTAssertTrue(favicon.downloadType == .webApplicationManifestFile)

                // Let the test know that we got our favicon back
                expectation.fulfill()
            } catch let error {
                XCTAssert(false, "Failed to download favicon from WebApplicationManifestFile header: \(error.localizedDescription)")
            }
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testCheckForMetaRefreshRedirect() {
        let expectation = self.expectation(description: "MetaRefreshRedirect HTML FaviconFind")

        Task {
            do {
                let favicon = try await FaviconFinder(
                    url: self.metaRefreshRedirectUrl,
                    preferredType: .html,
                    preferences: [:],
                    checkForMetaRefreshRedirect: true,
                    logEnabled: true
                ).downloadFavicon()

                // Ensure that our favicon is actually valid
                XCTAssertTrue(favicon.image.isValidImage)

                // Ensure that our favicon was retrieved from the desired source
                XCTAssertTrue(favicon.downloadType == .html)

                // Let the test know that we got our favicon back
                expectation.fulfill()
            } catch let error {
                XCTAssert(false, "Failed to download favicon from WebApplicationManifestFile header: \(error.localizedDescription)")
            }
        }

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    func testForeignEncoding() {
        let expectation = self.expectation(description: "Non-UTF8")

        Task {
            do {
                let favicon = try await FaviconFinder(url: self.nonUtf8EncodedWebsite).downloadFavicon()

                // Ensure that our favicon is actually valid
                XCTAssertTrue(favicon.image.isValidImage)

                // Let the test know that we got our favicon back
                expectation.fulfill()
            } catch let error {
                XCTAssert(false, "Failed to download favicon from HTML header: \(error.localizedDescription)")
            }
        }

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    func testNoImageDownload() {
        let expectation = self.expectation(description: "No Image Download")

        Task {
            do {
                let favicon = try await FaviconFinder(
                    url: self.realFaviconGeneratorUrl,
                    preferredType: .html,
                    preferences: [:],
                    downloadImage: false,
                    logEnabled: true
                ).downloadFavicon()

                // Ensure that our favicon is NOT valid
                #if !os(Linux)
                XCTAssertFalse(favicon.image.isValidImage)
                #endif

                // Ensure the URL was passed
                XCTAssertEqual(favicon.url.absoluteString, "https://realfavicongenerator.net/blog/wp-content/uploads/fbrfg/apple-touch-icon.png")

                // Let the test know that we got our favicon back
                expectation.fulfill()
            } catch let error {
                XCTAssert(false, "Failed to download favicon from HTML header: \(error.localizedDescription)")
            }
        }

        waitForExpectations(timeout: 10.0, handler: nil)
    }

}

private extension FaviconImage {

    var isValidImage: Bool {
        #if targetEnvironment(macCatalyst)
        return self.isValid

        #elseif canImport(AppKit)
        return self.isValid

        #elseif canImport(UIKit)
        return self.cgImage != nil || self.ciImage != nil

        #else // Linux and other non-Apple platforms
        return true // We'll leave this hardcoded as we Linux doesn't have an "image" type

        #endif
    }

}
