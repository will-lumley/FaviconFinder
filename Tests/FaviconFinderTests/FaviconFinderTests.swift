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

    func testIco() async throws {
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

    func testHtml() async throws {
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

    func testWebApplicationManifestFile() async throws {
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

    func testForeignEncoding() async throws {
        let favicon = try await FaviconFinder(url: .nonUtf8Encoded)
            .fetchFaviconURLs()
            .download()
            .first()

        // Ensure that our favicon is actually valid
        let image = try XCTUnwrap(favicon.image)
        XCTAssertTrue(image.isValidImage)
    }

    func testCancel() async throws {
        let faviconFinder = try await FaviconFinder(
            url: .google,
            configuration: .init(preferredSource: .mock)
        )

        let expectation = expectation(description: "Task should be cancelled")

        // Find the Favicon's in a separate Task
        Task {
            do {
                _ = try await faviconFinder.fetchFaviconURLs()
                XCTFail("Expected fetchFaviconURLs to be cancelled, but it completed")
            } catch is CancellationError {
                expectation.fulfill()
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }

        // Wait a moment to ensure the task starts
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // Cancel the finding
        faviconFinder.cancel()

        // Wait for the expectation to be fulfilled
        await fulfillment(of: [expectation], timeout: 5)
    }

}
