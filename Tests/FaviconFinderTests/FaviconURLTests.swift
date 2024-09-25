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

    @Test("Test Inferred Size", arguments: [
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
            sizeTag: sizeTag
        )

        let inferredSize = try #require(testSubject.inferredSize)
        #expect(inferredSize.width == CGFloat(rawWidth))
        #expect(inferredSize.height == CGFloat(rawHeight))
    }

}
