//
//  String+Removals.swift
//  FaviconFinderTests
//
//  Created by William Lumley on 21/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

import Foundation

/// An extension to `String` that provides a method for removing all characters
/// after the first occurrence of a specified substring, including the substring itself.
///
extension String {

    /// Finds the first occurrence of the provided string and removes everything after it,
    /// including the occurrence itself.
    ///
    /// If the substring is found, the string is truncated up to the point of the substring.
    /// If the substring is not found, the original string remains unchanged.
    ///
    /// - Parameter str: The substring to search for. Everything after this substring, including the substring itself, will be removed.
    ///
    /// - Example:
    ///   ```swift
    ///   var string = "Hello, World!"
    ///   string.removeEverythingAfter(str: "World")
    ///   // string is now "Hello, "
    ///   ```
    ///   
    public mutating func removeEverythingAfter(str: String) {
        let nsString = NSString(string: self)

        // This is the location/start-index of the occurence of 
        // str within our `self` string
        let locationOfOccurence = nsString.range(of: str).location

        // This is the range that makes up the index of the found occurence, '
        // til the end of the string
        let range = NSRange(location: locationOfOccurence, length: nsString.length - locationOfOccurence)

        if range.location != NSNotFound {
            self = nsString.replacingCharacters(in: range, with: "")
        }
    }

}
