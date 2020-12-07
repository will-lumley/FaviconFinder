//
//  FaviconFinderTests.swift
//  FaviconFinderTests
//
//  Created by William Lumley on 16/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

import XCTest

@testable import FaviconFinder

class FaviconFinderTests: XCTestCase {
    let googleUrl = URL(string: "https://google.com")!
    let appleUrl  = URL(string: "https://apple.com")!
    let realFaviconGeneratorUrl = URL(string: "https://realfavicongenerator.net/blog/apple-touch-icon-the-good-the-bad-the-ugly/")!

    override func setUp() {

    }

    override func tearDown() {

    }

    func testFaviconIcoFind() {
        let expectation = self.expectation(description: "Favicon.ico FaviconFind")

        FaviconFinder(url: self.googleUrl).downloadFavicon { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTAssert(false, "Failed to download favicon.ico file: \(error)")
            }
        }
        
        waitForExpectations(timeout: 20.0, handler: nil)
    }

    func testFaviconHtmlFind() {
        let expectation = self.expectation(description: "HTML FaviconFind")
        
        FaviconFinder(url: self.realFaviconGeneratorUrl).downloadFavicon { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTAssert(false, "Failed to download favicon from HTML header: \(error.localizedDescription)")
            }
        }
        
        waitForExpectations(timeout: 20.0, handler: nil)
    }
}
