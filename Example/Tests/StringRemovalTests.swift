//
//  StringRemovalTests.swift
//  FaviconFinderTests
//
//  Created by William Lumley on 21/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

import XCTest
import FaviconFinder

class StringRemovalTests: XCTestCase {

    override func setUp() {
        
    }

    override func tearDown() {
        
    }
    
    func testRemoveEverythingAfter() {
        var str = "abcdef1234"
        str.removeEverythingAfter(str: "12")
        
        XCTAssert(str == "abcdef", "RemoveEverythingAfter failed, str should be abcdef, but instead is \(str)")
    }
}
