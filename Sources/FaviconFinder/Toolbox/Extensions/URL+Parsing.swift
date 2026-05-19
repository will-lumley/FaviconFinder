//
//  URL+Parsing.swift
//  FaviconFinder
//
//  Created by William Lumley on 16/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

import Foundation

/// An extension to `URL` that provides utilities for manipulating and parsing URLs,
/// such as removing subdomains and stripping the scheme.
///
extension URL {

    /// Second-level domain labels that, when appearing directly before a ccTLD, form a compound TLD.
    ///
    /// For example, "co" before "uk" produces "co.uk", and "com" before "au" produces "com.au".
    /// This heuristic covers the overwhelming majority of real-world compound TLDs without
    /// requiring a full Public Suffix List.
    ///
    private static let secondLevelQualifiers: Set<String> = [
        "co", "com", "net", "org", "gov", "edu", "ac", "ne", "or", "id", "me", "in"
    ]

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
    /// Uses a heuristic to detect compound TLDs (e.g. `co.uk`, `com.au`): if the second-to-last
    /// dot-separated component is a known second-level qualifier, both components are treated as
    /// the TLD. This means any single- or compound-TLD URL is supported without a hardcoded list.
    ///
    /// - Returns: A new URL without subdomains, or `nil` if the host has fewer than two components.
    ///
    /// - Example:
    ///   ```swift
    ///   URL(string: "https://mail.google.com")!.urlWithoutSubdomains   // https://google.com
    ///   URL(string: "https://mail.google.co.uk")!.urlWithoutSubdomains // https://google.co.uk
    ///   URL(string: "https://sub.example.io")!.urlWithoutSubdomains    // https://example.io
    ///   ```
    ///
    public var urlWithoutSubdomains: URL? {
        guard var urlStr = self.absoluteStringWithoutScheme else {
            return nil
        }

        urlStr.removeEverythingAfter(str: "/")

        let components = urlStr.components(separatedBy: ".")

        guard components.count >= 2 else {
            return nil
        }

        let tldPart         = components[components.count - 1]
        let secondToLast    = components[components.count - 2]
        let isCompound      = URL.secondLevelQualifiers.contains(secondToLast)

        // For a compound TLD (e.g. co.uk) the root sits one position further left.
        let rootIndex = components.count - (isCompound ? 3 : 2)

        guard rootIndex >= 0 else {
            return nil
        }

        let rootDomain = components[rootIndex]
        let tld = isCompound ? "\(secondToLast).\(tldPart)" : tldPart

        return URL(string: "\(self.scheme ?? "https")://\(rootDomain).\(tld)")
    }

}
