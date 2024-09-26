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

    @Test("Inferred Size fro HTML Tag", arguments: [
        ("180x180", 180, 180),
        ("120x1080", 120, 1080),
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

    @Test("FaviconURL Size Sorting")
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

}
