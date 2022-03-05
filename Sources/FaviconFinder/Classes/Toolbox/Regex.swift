//
//  Regex.swift
//  FaviconFinder
//
//  Created by William Lumley on 16/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

import Foundation

class Regex {

    private var expression: NSRegularExpression?
    private var pattern: String

    init(_ pattern: String) {
        self.pattern = pattern
        
        do {
            self.expression = try NSRegularExpression(pattern: self.pattern, options: .caseInsensitive)
        }
        catch let error {
            print("Could NOT form regex from: \(self.pattern) due to error: \(error)")
        }
    }
    
    public func test(input: String) -> Bool {
        guard let expression = self.expression else {
            return false
        }
        
        let matches = expression.matches(in: input, options: .anchored, range: NSMakeRange(0, input.count))
        return matches.count > 0
    }
}

//MARK: - Static Functions

extension Regex {

    public static func testForHttpsOrHttp(input: String) -> Bool {
        let regex = Regex("^(http|https)://")
        return regex.test(input: input)
    }

}
