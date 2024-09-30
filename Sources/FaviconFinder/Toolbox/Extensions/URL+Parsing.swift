//
//  URL+Parsing.swift
//  FaviconFinder
//
//  Created by William Lumley on 16/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

import Foundation

/// An extension to `URL` that provides utilities for manipulating and parsing URLs,
/// such as removing subdomains, stripping the scheme, and defining recognized TLDs.
///
extension URL {

    /// A list of possible domain components that we recognize as TLDs (top-level domains).
    ///
    /// These are used when attempting to extract the root domain from a URL.
    /// - Returns: An array of TLD strings.
    ///
    public var tlds: [String] {
        return [
            "com",
            "com.au",
            "net",
            "org"
        ]
    }

    /// Removes the URL scheme (e.g., "https") from the URL string, leaving the rest of the URL intact.
    ///
    /// - Returns: A string representing the URL without its scheme, or `nil` if the scheme doesn't exist.
    ///
    /// - Example:
    ///   ```swift
    ///   let url = URL(string: "https://example.com/path")!
    ///   let stripped = url.absoluteStringWithoutScheme
    ///   // stripped is "example.com/path"
    ///   ```
    public var absoluteStringWithoutScheme: String? {
        guard let scheme = self.scheme else {
            return nil
        }

        var urlStr = self.absoluteString
        urlStr = urlStr.replacingOccurrences(of: "://", with: "")
        urlStr = urlStr.replacingOccurrences(of: scheme, with: "")

        return urlStr
    }

    /// Attempts to create a new URL by removing the subdomains from the current URL.
    ///
    /// For example, `https://emailer.netflix.com/foobar` would become `https://netflix.com`.
    ///
    /// - Returns: A new URL without subdomains, or `nil` if it couldn't be generated.
    ///
    /// - Example:
    ///   ```swift
    ///   let url = URL(string: "https://subdomain.example.com")!
    ///   let rootUrl = url.urlWithoutSubdomains
    ///   // rootUrl is "https://example.com"
    ///   ```
    ///   
    public var urlWithoutSubdomains: URL? {
        // Remove the scheme
        guard var urlStr = self.absoluteStringWithoutScheme else {
            return nil
        }

        // Remove the everything after the first trailing slash
        urlStr.removeEverythingAfter(str: "/")

        // Break up our string with into an exploded array using a '.' as the delimiter
        let components = urlStr.components(separatedBy: ".")

        // Iterate over each component
        for componentIndex in 0 ..< components.count {
            let component = components[componentIndex]

            // If this is the TLD, we can stop iterating
            if self.tlds.contains(component) {

                // We found the TLD, so the part before the TLD must be the root domain
                guard componentIndex > 0 else {
                    return nil
                }

                let secondLastPart = components[componentIndex - 1]
                let remainingParts = components[componentIndex ..< components.count]

                // Create our new URL starting from the scheme, the delimiter, 
                // then the root part of the URL, then the remaining TLD's.
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

                return URL(string: newURL)
            }
        }

        return nil
    }

}
