//
//  FaviconFinderTests.swift
//  FaviconFinderTests
//
//  Created by William Lumley on 16/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

import XCTest

@testable import FaviconFinder

class FaviconFinderTests: XCTestCase
{
    let googleUrl = URL(string: "https://google.com")!
    let appleUrl  = URL(string: "https://apple.com")!
    let realFaviconGeneratorUrl = URL(string: "https://realfavicongenerator.net/blog/apple-touch-icon-the-good-the-bad-the-ugly/")!

    override func setUp()
    {

    }

    override func tearDown()
    {

    }

    func testFaviconIcoFind()
    {
        let expectation = self.expectation(description: "Favicon.ico FaviconFind")
        
        let faviconFinder = FaviconFinder(url: self.googleUrl)
        faviconFinder.downloadFavicon({(image, url, error) in
            
            if let error = error {
                XCTAssert(false, "Failed to download favicon.ico file: \(error)")
                return
            }
            
            guard let _ = image else {
                XCTAssert(false, "Image from favicon.ico is nil.")
                return
            }
            
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 20.0, handler: nil)
    }

    func testFaviconHtmlFind()
    {
        let expectation = self.expectation(description: "HTML FaviconFind")
        
        let faviconFinder = FaviconFinder(url: self.realFaviconGeneratorUrl)
        faviconFinder.downloadFavicon({(image, url, error) in
            
            if let error = error {
                XCTAssert(false, "Failed to download favicon from HTML header: \(error.localizedDescription)")
                return
            }
            
            guard let _ = image else {
                XCTAssert(false, "Image from favicon from HTML header is nil.")
                return
            }
            
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 20.0, handler: nil)
    }
}
