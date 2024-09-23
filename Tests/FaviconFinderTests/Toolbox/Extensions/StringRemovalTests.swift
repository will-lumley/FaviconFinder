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
}
