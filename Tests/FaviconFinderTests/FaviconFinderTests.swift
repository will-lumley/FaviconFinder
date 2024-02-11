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

    // MARK: - Tests

    func testFaviconIcoFind() async throws {
        let favicon = try await FaviconFinder(
            url: .google,
            configuration: .init(preferredSource: .ico)
        )
            .fetchFaviconURLs()
            .download()
            .first()

        // Ensure that our favicon is actually valid
        let image = try XCTUnwrap(favicon.image)
        XCTAssertTrue(image.isValidImage)

        // Ensure that our favicon was retrieved from the desired source
        XCTAssertTrue(favicon.url.sourceType == .ico)
    }

    func testFaviconHtmlFind() async throws {
        let favicon = try await FaviconFinder(
            url: .w3Schools,
            configuration: .init(preferredSource: .html)
        )
            .fetchFaviconURLs()
            .download()
            .first()

        // Ensure that our favicon is actually valid
        let image = try XCTUnwrap(favicon.image)
        XCTAssertTrue(image.isValidImage)

        // Ensure that our favicon was retrieved from the desired source
        XCTAssertTrue(favicon.url.sourceType == .html)
    }

    func testFaviconWebApplicationManifestFileFind() async throws {
        let favicon = try await FaviconFinder(
            url: .webApplicationManifest,
            configuration: .init(preferredSource: .webApplicationManifestFile)
        )
            .fetchFaviconURLs()
            .download()
            .first()

        // Ensure that our favicon is actually valid
        let image = try XCTUnwrap(favicon.image)
        XCTAssertTrue(image.isValidImage)

        // Ensure that our favicon was retrieved from the desired source
        XCTAssertTrue(favicon.url.sourceType == .webApplicationManifestFile)
    }

    func testCheckForMetaRefreshRedirect() async throws {
        let favicon = try await FaviconFinder(
            url: .metaRefreshRedirect,
            configuration: .init(
                preferredSource: .html,
                checkForMetaRefreshRedirect: true
            )
        )
            .fetchFaviconURLs()
            .download()
            .first()

        // Ensure that our favicon is actually valid
        let image = try XCTUnwrap(favicon.image)
        XCTAssertTrue(image.isValidImage)

        // Ensure that our favicon was retrieved from the desired source
        XCTAssertTrue(favicon.url.sourceType == .html)
    }

    #if !os(Linux)
    func testForeignEncoding() async throws {
        let favicon = try await FaviconFinder(url: .nonUtf8Encoded)
            .fetchFaviconURLs()
            .download()
            .first()

        // Ensure that our favicon is actually valid
        let image = try XCTUnwrap(favicon.image)
        XCTAssertTrue(image.isValidImage)
    }
    #endif

}
