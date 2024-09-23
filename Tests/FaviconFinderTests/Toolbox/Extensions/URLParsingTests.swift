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

    @Test("URL Without Subdomains")
    func urlWithoutSubdomains() {
        guard let strippedGmailUrl = self.gmailUrl.urlWithoutSubdomains else {
            Issue.record("\(self.gmailUrl) without subdomains returned nil.")
            return
        }

        #expect(strippedGmailUrl == self.googleUrl)
    }

    @Test("Test AbsoluteString Without Scheme")
    func absoluteStringWithoutScheme() {
        guard let appleAuUrlWithoutScheme = self.appleAuUrl.absoluteStringWithoutScheme else {
            Issue.record("\(self.appleAuUrl) without subdomains returned nil.")
            return
        }

        #expect(appleAuUrlWithoutScheme == "apple.com/au")
    }
}
