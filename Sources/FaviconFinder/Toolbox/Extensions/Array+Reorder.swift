//
//  Array+Reorder.swift
//
//
//  Created by William Lumley on 9/2/2024.
//

import Foundation

extension Array where Element: Equatable {

    mutating func moveElementToFront(_ element: Element) {
        // Get the index of our desired element
        if let index = self.firstIndex(of: element) {
            // Remove it from our array
            let element = self.remove(at: index)

            // Insert it at the front of the queue
            self.insert(element, at: 0)
        }
    }

}
