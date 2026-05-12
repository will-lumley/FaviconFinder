//
//  FaviconFinderTests.swift
//  FaviconFinderTests
//
//  Created by William Lumley on 16/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

import FaviconFinder
import Foundation
import Testing

struct URLParsingTests {

    let gmailUrl  = URL(string: "https://mail.google.com")!
    let googleUrl = URL(string: "https://google.com")!

    let appleAuUrl = URL(string: "https://apple.com/au")!
    let appleUrl   = URL(string: "https://apple.com")!

    // MARK: - urlWithoutSubdomains

    @Test("Strips subdomain from URL")
    func urlWithoutSubdomains() {
        guard let strippedGmailUrl = self.gmailUrl.urlWithoutSubdomains else {
            Issue.record("\(self.gmailUrl) without subdomains returned nil.")
            return
        }

        #expect(strippedGmailUrl == self.googleUrl)
    }

    @Test("Root domain URL returns same URL")
    func urlWithoutSubdomainsAlreadyRoot() {
        let rootUrl = URL(string: "https://google.com")!
        let result = rootUrl.urlWithoutSubdomains
        #expect(result == rootUrl)
    }

    @Test("Unrecognized TLD returns nil")
    func urlWithoutSubdomainsUnknownTLD() {
        let url = URL(string: "https://example.io")!
        #expect(url.urlWithoutSubdomains == nil)
    }

    @Test("Strips subdomain from com.au TLD URL")
    func urlWithoutSubdomainsComAu() {
        let url = URL(string: "https://sub.apple.com.au/path")!
        let result = url.urlWithoutSubdomains
        #expect(result != nil)
        #expect(result?.absoluteString.contains("apple.com") == true)
    }

    // MARK: - absoluteStringWithoutScheme

    @Test("Strips scheme from URL")
    func absoluteStringWithoutScheme() {
        guard let appleAuUrlWithoutScheme = self.appleAuUrl.absoluteStringWithoutScheme else {
            Issue.record("\(self.appleAuUrl) without subdomains returned nil.")
            return
        }

        #expect(appleAuUrlWithoutScheme == "apple.com/au")
    }

    @Test("Strips https scheme from URL")
    func absoluteStringWithoutSchemeHttps() {
        let url = URL(string: "https://example.com/path")!
        #expect(url.absoluteStringWithoutScheme == "example.com/path")
    }

    @Test("Strips http scheme from URL")
    func absoluteStringWithoutSchemeHttp() {
        let url = URL(string: "http://example.com/path")!
        #expect(url.absoluteStringWithoutScheme == "example.com/path")
    }

    // MARK: - tlds

    @Test("tlds contains expected values")
    func tldsProperty() {
        let url = URL(string: "https://example.com")!
        let tlds = url.tlds
        #expect(tlds.contains("com"))
        #expect(tlds.contains("com.au"))
        #expect(tlds.contains("net"))
        #expect(tlds.contains("org"))
    }
}
