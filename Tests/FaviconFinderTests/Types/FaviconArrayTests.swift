//
//  FaviconArrayTests.swift
//  FaviconFinder
//

@testable import FaviconFinder
import Testing

struct FaviconArrayTests {

    // MARK: - first()

    @Test("first() throws on empty array")
    func firstThrowsOnEmpty() {
        let empty: [Favicon] = []
        #expect(throws: FaviconError.failedToFindFavicon) {
            try empty.first()
        }
    }

    // MARK: - largest()

    @Test("largest() throws on empty array")
    func largestThrowsOnEmpty() {
        let empty: [Favicon] = []
        #expect(throws: FaviconError.failedToFindFavicon) {
            try empty.largest()
        }
    }

    // MARK: - smallest()

    @Test("smallest() throws on empty array")
    func smallestThrowsOnEmpty() {
        let empty: [Favicon] = []
        #expect(throws: FaviconError.failedToFindFavicon) {
            try empty.smallest()
        }
    }

}
