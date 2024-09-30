//
//  Regex.swift
//  FaviconFinder
//
//  Created by William Lumley on 16/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

import Foundation

/// A utility class to encapsulate `NSRegularExpression` functionality.
/// Provides simple pattern matching capabilities for strings.
///
final class Regex {

    /// The compiled regular expression
    private var expression: NSRegularExpression?

    /// The pattern string to be compiled into a regular expression
    private var pattern: String

    /// Initializes the `Regex` object with a pattern string.
    ///
    /// - Parameter pattern: The regular expression pattern to compile.
    ///
    init(_ pattern: String) {
        self.pattern = pattern

        do {
            self.expression = try NSRegularExpression(pattern: self.pattern, options: .caseInsensitive)
        } catch let error {
            print("Could NOT form regex from: \(self.pattern) due to error: \(error)")
        }
    }

    /// Tests whether the input string matches the regular expression pattern.
    ///
    /// - Parameter input: The string to test.
    /// - Returns: A boolean value indicating if the input matches the regex pattern.
    ///
    public func test(input: String) -> Bool {
        guard let expression = self.expression else {
            return false
        }

        let matches = expression.matches(
            in: input,
            options: .anchored,
            range: .init(location: 0, length: input.count)
        )

        return matches.count > 0
    }

    /// A utility method to check if a string starts with "http" or "https".
    ///
    /// - Parameter input: The string to test.
    /// - Returns: A boolean indicating whether the input starts with "http" or "https".
    /// 
    static func testForHttpsOrHttp(input: String) -> Bool {
        let regex = Regex("^(http|https)://")
        return regex.test(input: input)
    }

}
