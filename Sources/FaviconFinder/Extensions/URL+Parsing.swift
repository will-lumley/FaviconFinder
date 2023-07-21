//
//  URL+Parsing.swift
//  FaviconFinder
//
//  Created by William Lumley on 16/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

import Foundation

extension URL {

    //TODO: Expand upon this
    /**
     A list of possible domain components that we recognise as TLDs
     */
    public var tlds: [String] {
        return [
            "com",
            "com.au",
            "net",
            "org"
        ]
    }
    
    /**
     https://stackoverflow.com/questions/17101227/how-to-extract-and-remove-scheme-name-from-nsurl
     */
    public var absoluteStringWithoutScheme: String? {
        guard let scheme = self.scheme else {
            return nil
        }
        
        var urlStr = self.absoluteString
        urlStr = urlStr.replacingOccurrences(of: "://", with: "")
        urlStr = urlStr.replacingOccurrences(of: scheme, with: "")
        
        return urlStr
    }
    
    /**
     Attempts to create a URL by removing the subdomains from self.
     For example, emailer.netflix.com/foobar would be netflix.com
     
     - returns: Nil if removing the subdomains was not possible, otherwise the new URL is returned
    */
    public var urlWithoutSubdomains: URL? {
        //Remove the scheme
        guard var urlStr = self.absoluteStringWithoutScheme else {
            return nil
        }
        
        //Remove the everything after the first trailing slash
        urlStr.removeEverythingAfter(str: "/")
        
        //Break up our string with into an exploded array using a '.' as the delimiter
        let components = urlStr.components(separatedBy: ".")
        
        //Iterate over each component
        for i in 0 ..< components.count {
            let component = components[i]
            
            //If this is the TLD, we can stop iterating
            if self.tlds.contains(component) {
                
                //We found the TLD, so the part before the TLD must be the root domain
                guard i > 0 else { return nil }
                let secondLastPart = components[i - 1]
                let remainingParts = components[i ..< components.count]

                //Create our new URL starting from the scheme, the delimiter, then the root part of the URL, then the remaining TLD's
                var newURL = self.scheme ?? "https"

                newURL += "://"
                newURL += secondLastPart
                newURL += "."

                for tldComponent in remainingParts {
                    newURL += tldComponent
                    
                    let isLastComponent = tldComponent == remainingParts.last
                    if !isLastComponent {
                        newURL += "."
                    }
                }
                
                //print("NewURL: \(newURL) from: \(self)")
                return URL(string: newURL)
            }
        }
        
        return nil
    }

}
