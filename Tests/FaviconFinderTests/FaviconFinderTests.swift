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

    func testURLs() async throws {
        // Remove the URL that requires meta-refresh redirect
        var testURLs = TestURL.allCases
        testURLs.removeAll { $0 == .metaRefreshRedirect }
        testURLs.removeAll { $0 == .nonUtf8Encoded }

        // Iterate over each URL and ensure that they can be fetched
        for url in testURLs {
            print("Fetching \(url)")
            try await self.fetch(url: url.url)
            print("Fetched \(url)")
        }
    }

    func testIco() async throws {
        let favicon = try await FaviconFinder(
            url: TestURL.google.url,
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
            url: TestURL.w3Schools.url,
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
            url: TestURL.webApplicationManifest.url,
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
            url: TestURL.metaRefreshRedirect.url,
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
        let favicon = try await FaviconFinder(url: TestURL.nonUtf8Encoded.url)
            .fetchFaviconURLs()
            .download()
            .first()

        // Ensure that our favicon is actually valid
        let image = try XCTUnwrap(favicon.image)
        XCTAssertTrue(image.isValidImage)
    }

    func testCancel() async throws {
        let faviconFinder = FaviconFinder(
            url: TestURL.google.url,
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

private extension FaviconFinderTests {

    func fetch(url: URL) async throws {
        let favicon = try await FaviconFinder(
            url: url,
            configuration: .init(preferredSource: .ico)
        )
            .fetchFaviconURLs()
            .download()
            .first()
        XCTAssertNotNil(favicon.image)
    }

}
