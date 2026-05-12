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

    @Test("Invalid URL string returns nil")
    func invalidURLReturnsNil() {
        let invalid = "not a url %%"
        #expect(invalid.valueOfQueryParam("key") == nil)
    }

    @Test("URL with no query params returns nil")
    func noQueryParamsReturnsNil() {
        let url = "https://example.com/path"
        #expect(url.valueOfQueryParam("key") == nil)
    }

    @Test("URL with empty query string returns nil for any key")
    func emptyQueryString() {
        let url = "https://example.com?"
        #expect(url.valueOfQueryParam("key") == nil)
    }

}
