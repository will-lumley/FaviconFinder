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

    @Test("Moving element in empty array returns empty array")
    func testReorderEmpty() {
        let empty = [Int]()
        let result = empty.movingElementToFront(1)
        #expect(result == [])
    }

    @Test("Moving element in single-element array is unchanged")
    func testReorderSingleElement() {
        let array = [42]
        let result = array.movingElementToFront(42)
        #expect(result == [42])
    }

}
