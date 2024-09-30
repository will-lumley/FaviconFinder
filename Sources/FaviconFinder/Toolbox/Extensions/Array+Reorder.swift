//
//  Array+Reorder.swift
//
//
//  Created by William Lumley on 9/2/2024.
//

import Foundation

/// An extension to `Array` for types that conform to `Equatable`.
/// Provides a method to move a specified element to the front of the array.
///
/// This can be useful when you want to reorder an array by moving a particular
/// element to the front while maintaining the order of the remaining elements.
/// 
extension Array where Element: Equatable {

    /// Returns a new array with the specified element moved to the front, if it exists.
    /// The original order of other elements is maintained.
    ///
    /// - Parameter element: The element you want to move to the front of the array.
    ///
    /// - Returns: A new array where the specified element is moved to the front,
    ///            or the same array if the element is not found.
    ///
    /// - Example:
    ///   ```
    ///   let array = [1, 2, 3, 4]
    ///   let newArray = array.movingElementToFront(3)
    ///   // newArray is [3, 1, 2, 4]
    ///   ```
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
