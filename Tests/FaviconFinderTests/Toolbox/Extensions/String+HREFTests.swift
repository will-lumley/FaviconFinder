//
//  String+HREFTests.swift
//  FaviconFinder
//

@testable import FaviconFinder
import Foundation
import SwiftSoup
import Testing

struct StringHREFTests {

    private let pageURL = URL(string: "https://example.com")!

    private func makeHead(html: String = "<html><head></head></html>") throws -> SwiftSoup.Element {
        let document = try SwiftSoup.parse(html)
        return try #require(document.head())
    }

    @Test("Absolute URL is returned as URL directly")
    func absoluteURL() throws {
        let head = try makeHead()
        let href = "https://cdn.example.com/icon.png"
        let result = href.baseUrl(from: head, from: pageURL)
        #expect(result?.absoluteString == href)
    }

    @Test("Absolute HTTP URL is returned as URL directly")
    func absoluteHttpURL() throws {
        let head = try makeHead()
        let href = "http://cdn.example.com/icon.png"
        let result = href.baseUrl(from: head, from: pageURL)
        #expect(result?.absoluteString == href)
    }

    @Test("Relative URL is resolved against page base URL")
    func relativeURLResolvesAgainstPageURL() throws {
        let head = try makeHead()
        let href = "/images/icon.png"
        let result = href.baseUrl(from: head, from: pageURL)
        #expect(result?.absoluteString == "https://example.com/images/icon.png")
    }

    @Test("Relative URL is resolved against HTML base tag when present")
    func relativeURLResolvesAgainstBaseTag() throws {
        let head = try makeHead(html: """
        <html><head>
        <base href="https://cdn.example.com/">
        </head></html>
        """)
        let href = "icons/icon.png"
        let result = href.baseUrl(from: head, from: pageURL)
        #expect(result?.absoluteString.contains("cdn.example.com") == true)
        #expect(result?.absoluteString.contains("icons/icon.png") == true)
    }

    @Test("Relative URL falls back to page URL when base tag href is invalid")
    func relativeURLFallsBackToPageURL() throws {
        let head = try makeHead()
        let href = "favicon.ico"
        let result = href.baseUrl(from: head, from: pageURL)
        #expect(result != nil)
        #expect(result?.absoluteString.contains("example.com") == true)
    }

}
