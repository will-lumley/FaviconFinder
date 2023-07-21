//
//  String+Removals.swift
//  FaviconFinderTests
//
//  Created by William Lumley on 21/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

import Foundation

extension String {

    /**
     Finds the first instance of the provided string occurences, and removes everything after it,
     including the provided string itself
     - parameter str: The string occurence which we're looking for
     */
    public mutating func removeEverythingAfter(str: String) {
        let nsString = NSString(string: self)
        
        //This is the location/start-index of the occurence of str within our `self` string
        let locationOfOccurence = nsString.range(of: str).location
        
        //This is the range that makes up the index of the found occurence, 'till the end of the string
        let range = NSRange(location: locationOfOccurence, length: nsString.length - locationOfOccurence)
        
        if range.location != NSNotFound {
            self = nsString.replacingCharacters(in: range, with: "")
        }
    }

}
