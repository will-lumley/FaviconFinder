//
//  RegexTests.swift
//  FaviconFinderTests
//
//  Created by William Lumley on 16/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

import XCTest

@testable import FaviconFinder

class RegexTests: XCTestCase {
    let plainWebsite = "google.com"
    let httpWebsite  = "http://google.com"
    let httpsWebsite = "https://google.com"
    
    override func setUp() {
        
    }

    override func tearDown() {
        
    }
    
    func testRegexTest() {
        let regex = Regex("go+gle")
        XCTAssert(regex.test(input: "goooooogle"))
    }
    
    func testRegexTestForHttpsOrHttp() {
        XCTAssert(Regex.testForHttpsOrHttp(input: httpWebsite))
        XCTAssert(Regex.testForHttpsOrHttp(input: httpsWebsite))
        XCTAssert(Regex.testForHttpsOrHttp(input: plainWebsite) == false)
    }
}
