//
//  ArrayReorderTests.swift
//  FaviconFinder
//
//  Created by William Lumley on 9/2/24.
//  Copyright © 2024 William Lumley. All rights reserved.
//

@testable import FaviconFinder
import Testing

struct ArrayReorderTests {

    @Test("Reorder Elements")
    func testReorder() {
        var array = [Int]()

        array = [1, 2, 3]
        array = array.movingElementToFront(2)

        #expect(array == [2, 1, 3])

        array = [1, 2, 3]
        array = array.movingElementToFront(1)

        #expect(array == [1, 2, 3])

        array = [1, 2, 3]
        array = array.movingElementToFront(4)

        #expect(array == [1, 2, 3])
    }

}
