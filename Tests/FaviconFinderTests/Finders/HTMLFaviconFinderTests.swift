//
//  HTMLFaviconFinderTests.swift
//  FaviconFinder
//

@testable import FaviconFinder
import Foundation
import SwiftSoup
import Testing

struct HTMLFaviconFinderTests {

    private let baseURL = URL(string: "https://example.com")!

    private func config(
        html: String,
        acceptHeaderImage: Bool = false,
        htmlPreference: String? = nil
    ) throws -> FaviconFinder.Configuration {
        let document = try SwiftSoup.parse(html)
        var preferences: [FaviconSourceType: String] = [:]
        if let htmlPreference {
            preferences[.html] = htmlPreference
        }
        return .init(
            preferences: preferences,
            prefetchedHTML: document,
            acceptHeaderImage: acceptHeaderImage
        )
    }

    // MARK: - Link Tags

    @Test("Finds apple-touch-icon link tag")
    func appleTouchIconLink() async throws {
        let html = """
        <html><head>
        <link rel="apple-touch-icon" href="https://example.com/icon.png" sizes="180x180">
        </head></html>
        """
        let finder = HTMLFaviconFinder(url: baseURL, configuration: try config(html: html))
        let urls = try await finder.find()
        #expect(urls.count == 1)
        #expect(urls[0].format == .appleTouchIcon)
        #expect(urls[0].sourceType == .html)
        #expect(urls[0].size == FaviconSize(width: 180, height: 180))
    }

    @Test("Finds icon link tag")
    func iconLink() async throws {
        let html = """
        <html><head>
        <link rel="icon" href="https://example.com/favicon.ico">
        </head></html>
        """
        let finder = HTMLFaviconFinder(url: baseURL, configuration: try config(html: html))
        let urls = try await finder.find()
        #expect(urls.count == 1)
        #expect(urls[0].format == .icon)
    }

    @Test("Finds shortcut icon link tag")
    func shortcutIconLink() async throws {
        let html = """
        <html><head>
        <link rel="shortcut icon" href="https://example.com/favicon.ico">
        </head></html>
        """
        let finder = HTMLFaviconFinder(url: baseURL, configuration: try config(html: html))
        let urls = try await finder.find()
        #expect(urls.count == 1)
        #expect(urls[0].format == .shortcutIcon)
    }

    @Test("Finds apple-touch-icon-precomposed link tag")
    func appleTouchIconPrecomposedLink() async throws {
        let html = """
        <html><head>
        <link rel="apple-touch-icon-precomposed" href="https://example.com/icon-pre.png">
        </head></html>
        """
        let finder = HTMLFaviconFinder(url: baseURL, configuration: try config(html: html))
        let urls = try await finder.find()
        #expect(urls.count == 1)
        #expect(urls[0].format == .appleTouchIconPrecomposed)
    }

    @Test("Resolves relative href against page base URL")
    func relativeHrefResolvesAgainstBaseURL() async throws {
        let html = """
        <html><head>
        <link rel="apple-touch-icon" href="/images/icon.png">
        </head></html>
        """
        let finder = HTMLFaviconFinder(url: baseURL, configuration: try config(html: html))
        let urls = try await finder.find()
        #expect(urls.count == 1)
        #expect(urls[0].source.absoluteString == "https://example.com/images/icon.png")
    }

    @Test("Resolves relative href against HTML base tag")
    func relativeHrefResolvesAgainstBaseTag() async throws {
        let html = """
        <html><head>
        <base href="https://cdn.example.com/">
        <link rel="apple-touch-icon" href="icons/icon.png">
        </head></html>
        """
        let finder = HTMLFaviconFinder(url: baseURL, configuration: try config(html: html))
        let urls = try await finder.find()
        #expect(urls.count == 1)
        #expect(urls[0].source.absoluteString.contains("cdn.example.com"))
    }

    @Test("Ignores non-favicon link tags")
    func ignoresNonFaviconLinks() async throws {
        let html = """
        <html><head>
        <link rel="stylesheet" href="https://example.com/style.css">
        <link rel="canonical" href="https://example.com/">
        <link rel="manifest" href="https://example.com/manifest.json">
        <link rel="apple-touch-icon" href="https://example.com/icon.png">
        </head></html>
        """
        let finder = HTMLFaviconFinder(url: baseURL, configuration: try config(html: html))
        let urls = try await finder.find()
        #expect(urls.count == 1)
        #expect(urls[0].format == .appleTouchIcon)
    }

    @Test("Returns multiple favicons when multiple link tags present")
    func multipleLinks() async throws {
        let html = """
        <html><head>
        <link rel="apple-touch-icon" href="https://example.com/touch-icon.png" sizes="180x180">
        <link rel="icon" href="https://example.com/favicon.ico">
        <link rel="shortcut icon" href="https://example.com/shortcut.ico">
        </head></html>
        """
        let finder = HTMLFaviconFinder(url: baseURL, configuration: try config(html: html))
        let urls = try await finder.find()
        #expect(urls.count == 3)
    }

    // MARK: - Meta Tags

    @Test("Excludes og:image when acceptHeaderImage is false")
    func excludesOgImageByDefault() async throws {
        let html = """
        <html><head>
        <meta property="og:image" content="https://example.com/social.png">
        </head></html>
        """
        let finder = HTMLFaviconFinder(url: baseURL, configuration: try config(html: html, acceptHeaderImage: false))
        await #expect(throws: FaviconError.failedToFindFavicon) {
            try await finder.find()
        }
    }

    @Test("Includes og:image when acceptHeaderImage is true")
    func includesOgImageWhenAccepted() async throws {
        let html = """
        <html><head>
        <meta property="og:image" content="https://example.com/social.png">
        </head></html>
        """
        let finder = HTMLFaviconFinder(url: baseURL, configuration: try config(html: html, acceptHeaderImage: true))
        let urls = try await finder.find()
        #expect(urls.count == 1)
        #expect(urls[0].format == .metaOpenGraphImage)
        #expect(urls[0].sourceType == .html)
    }

    @Test("Finds thumbnail meta tag")
    func thumbnailMeta() async throws {
        let html = """
        <html><head>
        <meta name="thumbnail" content="https://example.com/thumb.png">
        </head></html>
        """
        let finder = HTMLFaviconFinder(url: baseURL, configuration: try config(html: html))
        let urls = try await finder.find()
        #expect(urls.count == 1)
        #expect(urls[0].format == .metaThumbnail)
    }

    @Test("Finds both link and meta favicons in same document")
    func linkAndMetaTogether() async throws {
        let html = """
        <html><head>
        <link rel="apple-touch-icon" href="https://example.com/icon.png">
        <meta name="thumbnail" content="https://example.com/thumb.png">
        </head></html>
        """
        let finder = HTMLFaviconFinder(url: baseURL, configuration: try config(html: html))
        let urls = try await finder.find()
        #expect(urls.count == 2)
    }

    // MARK: - Error Cases

    @Test("Throws failedToFindFavicon when no favicons in HTML")
    func throwsWhenNoFavicons() async throws {
        let html = """
        <html><head>
        <title>No Favicons Here</title>
        </head></html>
        """
        let finder = HTMLFaviconFinder(url: baseURL, configuration: try config(html: html))
        await #expect(throws: FaviconError.failedToFindFavicon) {
            try await finder.find()
        }
    }

    // MARK: - preferredType

    @Test("preferredType defaults to apple-touch-icon")
    func preferredTypeDefault() {
        let finder = HTMLFaviconFinder(url: baseURL, configuration: .defaultConfiguration)
        #expect(finder.preferredType == FaviconFormatType.appleTouchIcon.rawValue)
    }

    @Test("preferredType uses configuration preferences")
    func preferredTypeCustom() {
        let finder = HTMLFaviconFinder(
            url: baseURL,
            configuration: .init(preferences: [.html: FaviconFormatType.icon.rawValue])
        )
        #expect(finder.preferredType == FaviconFormatType.icon.rawValue)
    }

}
