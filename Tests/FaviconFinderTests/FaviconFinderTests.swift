//
//  FaviconFinderTests.swift
//  FaviconFinderTests
//
//  Created by William Lumley on 16/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

@testable import FaviconFinder
import Foundation
import Testing

struct FaviconFinderTests {

    // MARK: - Tests

    @Test("Test URLs")
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

    @Test("Test ICO Favicon")
    func testIco() async throws {
        let favicon = try await FaviconFinder(
            url: TestURL.google.url,
            configuration: .init(preferredSource: .ico)
        )
            .fetchFaviconURLs()
            .download()
            .first()

        // Ensure that our favicon is actually valid
        let image = try #require(favicon.image)
        #expect(image.isValidImage == true)

        // Ensure that our favicon was retrieved from the desired source
        #expect(favicon.url.sourceType == .ico)
    }

    @Test("Test HTML Favicon")
    func testHtml() async throws {
        let favicon = try await FaviconFinder(
            url: TestURL.w3Schools.url,
            configuration: .init(preferredSource: .html)
        )
            .fetchFaviconURLs()
            .download()
            .first()

        // Ensure that our favicon is actually valid
        let image = try #require(favicon.image)
        #expect(image.isValidImage == true)

        // Ensure that our favicon was retrieved from the desired source
        #expect(favicon.url.sourceType == .html)
    }

    @Test("Test WebApplicationManifestFile Favicon")
    func testWebApplicationManifestFile() async throws {
        let favicon = try await FaviconFinder(
            url: TestURL.webApplicationManifest.url,
            configuration: .init(preferredSource: .webApplicationManifestFile)
        )
            .fetchFaviconURLs()
            .download()
            .first()

        // Ensure that our favicon is actually valid
        let image = try #require(favicon.image)
        #expect(image.isValidImage == true)

        // Ensure that our favicon was retrieved from the desired source
        #expect(favicon.url.sourceType == .webApplicationManifestFile)
    }

    @Test("Test Meta Refresh Redirect Favicon")
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
        let image = try #require(favicon.image)
        #expect(image.isValidImage == true)

        // Ensure that our favicon was retrieved from the desired source
        #expect(favicon.url.sourceType == .html)
    }

    @Test("Test ForeignEncoding Favicon")
    func testForeignEncoding() async throws {
        let favicon = try await FaviconFinder(url: TestURL.nonUtf8Encoded.url)
            .fetchFaviconURLs()
            .download()
            .first()

        // Ensure that our favicon is actually valid
        let image = try #require(favicon.image)
        #expect(image.isValidImage == true)
    }

//    @Test("Test Cancel", .disabled())
//    func testCancel() async throws {
//        let faviconFinder = FaviconFinder(
//            url: TestURL.google.url,
//            configuration: .init(preferredSource: .mock)
//        )
//
//        // We're expecting to catch an error, and we'll store it here
//        var caughtError: Error?
//
//        // Find the Favicon's in a separate Task, so we can cancel it
//        Task {
//            do {
//                _ = try await faviconFinder.fetchFaviconURLs()
//                Issue.record("Expected fetchFaviconURLs to be cancelled, but it completed")
//            } catch {
//                // Store the error
//                caughtError = error
//            }
//        }
//
//        // Wait a moment to ensure the task starts
//        try await Task.sleep(nanoseconds: 1_000_000_000)
//
//        // Cancel the finding
//        faviconFinder.cancel()
//
//        // Wait a couple seconds
//        try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
//
//        // We got a CancellationError, meaning that we got a cancellation, yay
//        #expect(caughtError is CancellationError)
//    }

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

        #expect(favicon.image != nil)
    }

}
