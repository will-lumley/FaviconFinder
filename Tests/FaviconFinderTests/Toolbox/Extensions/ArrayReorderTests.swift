//
//  ArrayReorderTests.swift
//  FaviconFinder
//
//  Created by William Lumley on 9/2/24.
//  Copyright © 2024 William Lumley. All rights reserved.
//

@testable import FaviconFinder
import XCTest

class ArrayReorderTests: XCTestCase {

    func testReorder() {
        var array = [Int]()

        array = [1, 2, 3]
        array.moveElementToFront(2)
        XCTAssertEqual(array, [2, 1, 3])

        array = [1, 2, 3]
        array.moveElementToFront(1)
        XCTAssertEqual(array, [1, 2, 3])

        array = [1, 2, 3]
        array.moveElementToFront(4)
        XCTAssertEqual(array, [1, 2, 3])
    }

}
