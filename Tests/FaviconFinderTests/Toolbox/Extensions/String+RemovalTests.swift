//
//  StringRemovalTests.swift
//  FaviconFinderTests
//
//  Created by William Lumley on 21/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

import FaviconFinder
import Testing

struct StringRemovalTests {

    @Test("Test Remove Everything After")
    func removeEverythingAfter() {
        var str = "abcdef1234"
        str.removeEverythingAfter(str: "12")

        #expect(str == "abcdef")
    }

    @Test("Substring not found leaves string unchanged")
    func removeEverythingAfterNotFound() {
        var str = "abcdef"
        str.removeEverythingAfter(str: "xyz")

        #expect(str == "abcdef")
    }

    @Test("Removes from first occurrence when substring appears multiple times")
    func removeEverythingAfterFirstOccurrence() {
        var str = "aabcbc"
        str.removeEverythingAfter(str: "b")

        #expect(str == "aa")
    }
}
