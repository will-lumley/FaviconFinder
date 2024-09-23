//
//  Array+Reorder.swift
//
//
//  Created by William Lumley on 9/2/2024.
//

import Foundation

extension Array where Element: Equatable {

    func movingElementToFront(_ element: Element) -> [Element] {
        var newArray = self

        // Get the index of our desired element
        if let index = newArray.firstIndex(of: element) {
            // Remove it from our array
            let element = newArray.remove(at: index)

            // Insert it at the front of the queue
            newArray.insert(element, at: 0)
        }
        return newArray
    }

}
