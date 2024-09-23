//
//  RegexTests.swift
//  FaviconFinderTests
//
//  Created by William Lumley on 16/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

@testable import FaviconFinder
import Testing

struct RegexTests {

    // MARK: - Properties

    let plainWebsite = "google.com"
    let httpWebsite  = "http://google.com"
    let httpsWebsite = "https://google.com"

    // MARK: - Tests

    @Test("Test Regex")
    func regexTest() {
        let regex = Regex("go+gle")
        #expect(regex.test(input: "goooooogle") == true)
    }

    @Test("Test Regex for HTTP or HTTPS")
    func regexTestForHttpsOrHttp() {
        #expect(Regex.testForHttpsOrHttp(input: httpWebsite) == true)
        #expect(Regex.testForHttpsOrHttp(input: httpsWebsite) == true)
        #expect(Regex.testForHttpsOrHttp(input: plainWebsite) == false)
    }
}
