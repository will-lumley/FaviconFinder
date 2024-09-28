//
//  String+URLQueryTests.swift
//  FaviconFinder
//
//  Created by William Lumley on 26/9/2024.
//

@testable import FaviconFinder
import Testing

struct StringURLQueryTests {

    @Test("Pull Query Params")
    func pullQueryParams() {
        let testSubject = "https://google.com?foo=1&bar=3&foobar=helloworld"

        #expect(testSubject.valueOfQueryParam("foo") == "1")
        #expect(testSubject.valueOfQueryParam("bar") == "3")
        #expect(testSubject.valueOfQueryParam("foobar") == "helloworld")
        #expect(testSubject.valueOfQueryParam("nothing") == nil)
    }

}
