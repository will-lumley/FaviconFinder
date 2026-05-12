//
//  WebApplicationManifestFaviconFinderTests.swift
//  FaviconFinder
//

@testable import FaviconFinder
import Foundation
import SwiftSoup
import Testing

struct WebApplicationManifestFaviconFinderTests {

    private let baseURL = URL(string: "https://example.com")!

    // MARK: - Unit Tests (no network)

    @Test("Throws failedToFindWebApplicationManifestFile when no manifest link in HTML")
    func throwsWhenNoManifestLink() async throws {
        let html = """
        <html><head>
        <link rel="apple-touch-icon" href="https://example.com/icon.png">
        </head></html>
        """
        let document = try SwiftSoup.parse(html)
        let finder = WebApplicationManifestFaviconFinder(
            url: baseURL,
            configuration: .init(prefetchedHTML: document)
        )
        await #expect(throws: FaviconError.failedToFindWebApplicationManifestFile) {
            try await finder.find()
        }
    }

    @Test("Throws failedToFindWebApplicationManifestFile when HTML head has no links at all")
    func throwsWhenEmptyHead() async throws {
        let html = "<html><head></head></html>"
        let document = try SwiftSoup.parse(html)
        let finder = WebApplicationManifestFaviconFinder(
            url: baseURL,
            configuration: .init(prefetchedHTML: document)
        )
        await #expect(throws: FaviconError.failedToFindWebApplicationManifestFile) {
            try await finder.find()
        }
    }

    // MARK: - preferredType

    @Test("preferredType defaults to manifest")
    func preferredTypeDefault() {
        let finder = WebApplicationManifestFaviconFinder(url: baseURL, configuration: .defaultConfiguration)
        #expect(finder.preferredType == "manifest")
    }

    @Test("preferredType uses configuration preferences")
    func preferredTypeCustom() {
        let config = FaviconFinder.Configuration(
            preferences: [.webApplicationManifestFile: "custom-manifest"]
        )
        let finder = WebApplicationManifestFaviconFinder(url: baseURL, configuration: config)
        #expect(finder.preferredType == "custom-manifest")
    }

}
