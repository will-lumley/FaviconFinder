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

    @Test("Test ForeignEncoding Favicon", .disabled())
    func testForeignEncoding() async throws {
        let favicon = try await FaviconFinder(url: TestURL.nonUtf8Encoded.url)
            .fetchFaviconURLs()
            .download()
            .first()

        // Ensure that our favicon is actually valid
        let image = try #require(favicon.image)
        #expect(image.isValidImage == true)
    }

    @Test("Test Cancel")
    func testCancel() async throws {
        let faviconFinder = FaviconFinder(
            url: TestURL.google.url,
            configuration: .init(preferredSource: .mock)
        )

        // Start fetching in a separate task so we can cancel it mid-flight.
        // MockFaviconFinder sleeps for 5 seconds, so there's plenty of time.
        let fetchTask = Task {
            try await faviconFinder.fetchFaviconURLs()
        }

        // Wait for the mock finder to begin its sleep
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // Cancel the internal task
        faviconFinder.cancel()

        // Await the outer task and assert we got a CancellationError
        var caughtError: Error?
        do {
            _ = try await fetchTask.value
            Issue.record("Expected fetchFaviconURLs to throw CancellationError, but it completed")
        } catch {
            caughtError = error
        }

        #expect(caughtError is CancellationError)
    }

    @Test("Test Largest Favicon from downloaded array")
    func testLargest() async throws {
        let favicons = try await FaviconFinder(
            url: TestURL.w3Schools.url,
            configuration: .init(preferredSource: .html)
        )
            .fetchFaviconURLs()
            .download()

        let largest = try favicons.largest()
        let image = try #require(largest.image)
        #expect(image.isValidImage == true)
    }

    @Test("Test Smallest Favicon from downloaded array")
    func testSmallest() async throws {
        let favicons = try await FaviconFinder(
            url: TestURL.w3Schools.url,
            configuration: .init(preferredSource: .html)
        )
            .fetchFaviconURLs()
            .download()

        let smallest = try favicons.smallest()
        let image = try #require(smallest.image)
        #expect(image.isValidImage == true)
    }

    @Test("Test FaviconURL single download")
    func testFaviconURLDownload() async throws {
        // Use the ICO favicon URL directly (not the homepage)
        let faviconURL = FaviconURL(
            source: URL(string: "https://www.google.com/favicon.ico")!,
            format: .ico,
            sourceType: .ico
        )
        let favicon = try await faviconURL.download()
        let image = try #require(favicon.image)
        #expect(image.isValidImage == true)
    }

    @Test("Test Mock Source")
    func testMockSource() async throws {
        let urls = try await FaviconFinder(
            url: TestURL.google.url,
            configuration: .init(preferredSource: .mock)
        )
            .fetchFaviconURLs()

        #expect(urls.isEmpty == false)
        #expect(urls.allSatisfy { $0.sourceType == .html })
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

        #expect(favicon.image != nil)
    }

}
