//
//  FaviconFinderTests.swift
//  FaviconFinderTests
//
//  Created by William Lumley on 16/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

import XCTest
import FaviconFinder

class URLParsingTests: XCTestCase {
    let gmailUrl  = URL(string: "https://mail.google.com")!
    let googleUrl = URL(string: "https://google.com")!

    let appleAuUrl = URL(string: "https://apple.com/au")!
    let appleUrl   = URL(string: "https://apple.com")!
    
    override func setUp() {

    }

    override func tearDown() {
        
    }
    
    func testUrlWithoutSubdomains() {
        guard let strippedGmailUrl = self.gmailUrl.urlWithoutSubdomains else {
            XCTAssert(false, "\(self.gmailUrl) without subdomains returned nil.")
            return
        }
        
        XCTAssert(strippedGmailUrl == self.googleUrl, "Stripped Gmail URL returned \(strippedGmailUrl)")
    }

    func testAbsoluteStringWithoutScheme() {
        guard let appleAuUrlWithoutScheme = self.appleAuUrl.absoluteStringWithoutScheme else {
            XCTAssert(false, "\(self.appleAuUrl) without scheme returned nil.")
            return
        }
        
        XCTAssert(appleAuUrlWithoutScheme == "apple.com/au", "Stripped AppleAu URL returned \(appleAuUrlWithoutScheme)")
    }
}
