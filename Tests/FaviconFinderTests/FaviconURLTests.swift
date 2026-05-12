//
//  FaviconURLTests.swift
//  FaviconFinder
//
//  Created by William Lumley on 24/9/2024.
//

import CoreFoundation
@testable import FaviconFinder
import Testing

struct FaviconURLTests {

    // MARK: - Inferred Size

    @Test("Inferred Size from HTML Tag", arguments: [
        ("180x180", 180.0, 180.0),
        ("120x1080", 120.0, 1080.0),
        ("100.50x20.02", 100.50, 20.02)
    ])
    func testInferredSize(
        sizeTag: String,
        rawWidth: Double,
        rawHeight: Double
    ) throws {
        let testSubject = FaviconURL(
            source: TestURL.google.url,
            format: .appleTouchIcon,
            sourceType: .html,
            htmlSizeTag: sizeTag
        )

        #expect(testSubject.size == .init(width: rawWidth, height: rawHeight))
    }

    @Test("Nil HTML size tag produces nil size")
    func nilSizeTag() {
        let url = FaviconURL(
            source: TestURL.google.url,
            format: .appleTouchIcon,
            sourceType: .html,
            htmlSizeTag: nil
        )
        #expect(url.size == nil)
    }

    @Test("HTML size tag with no x separator produces nil size")
    func sizeTagNoSeparator() {
        let url = FaviconURL(
            source: TestURL.google.url,
            format: .appleTouchIcon,
            sourceType: .html,
            htmlSizeTag: "180"
        )
        #expect(url.size == nil)
    }

    @Test("HTML size tag with non-numeric components produces nil size")
    func sizeTagNonNumeric() {
        let url = FaviconURL(
            source: TestURL.google.url,
            format: .appleTouchIcon,
            sourceType: .html,
            htmlSizeTag: "abcxdef"
        )
        #expect(url.size == nil)
    }

    // MARK: - Size Sorting

    @Test("FaviconURL array largest and smallest")
    func testSizeSorting() async throws {
        let testSubject = [
            FaviconURL(
                source: TestURL.google.url,
                format: .appleTouchIcon,
                sourceType: .html,
                htmlSizeTag: "100x100"
            ),
            FaviconURL(
                source: TestURL.google.url,
                format: .appleTouchIcon,
                sourceType: .html,
                htmlSizeTag: "180x180"
            ),
            FaviconURL(
                source: TestURL.google.url,
                format: .appleTouchIcon,
                sourceType: .html,
                htmlSizeTag: "181x181"
            ),
            FaviconURL(
                source: TestURL.google.url,
                format: .appleTouchIcon,
                sourceType: .html,
                htmlSizeTag: "150x150"
            )
        ]

        let largest = try await testSubject.largest()
        #expect(largest == testSubject[2])

        let smallest = try await testSubject.smallest()
        #expect(smallest == testSubject[0])
    }

    @Test("largest() throws on empty FaviconURL array")
    func largestThrowsOnEmpty() async {
        let empty: [FaviconURL] = []
        await #expect(throws: FaviconError.failedToFindFavicon) {
            try await empty.largest()
        }
    }

    @Test("smallest() throws on empty FaviconURL array")
    func smallestThrowsOnEmpty() async {
        let empty: [FaviconURL] = []
        await #expect(throws: FaviconError.failedToFindFavicon) {
            try await empty.smallest()
        }
    }

    @Test("Non-empty array with all-nil sizes still returns a FaviconURL from largest()")
    func largestWithAllNilSizes() async throws {
        let urls = [
            FaviconURL(source: TestURL.google.url, format: .appleTouchIcon, sourceType: .html, size: nil),
            FaviconURL(source: TestURL.apple.url, format: .icon, sourceType: .html, size: nil)
        ]
        let result = try await urls.largest()
        #expect(urls.contains(result))
    }

    // MARK: - Init

    @Test("Init with explicit size stores size")
    func initWithExplicitSize() {
        let size = FaviconSize(width: 64, height: 64)
        let url = FaviconURL(
            source: TestURL.google.url,
            format: .icon,
            sourceType: .ico,
            size: size
        )
        #expect(url.size == size)
        #expect(url.format == .icon)
        #expect(url.sourceType == .ico)
    }

}
