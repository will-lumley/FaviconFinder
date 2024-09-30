//
//  String+HREF.swift
//  
//
//  Created by William Lumley on 11/2/2024.
//

import Foundation
import SwiftSoup

/// An extension to `String` that helps resolve relative URLs (`href` attributes)
/// by determining the base URL using the HTML `<head>` element and the current URL context.
///
extension String {

    /// Resolves the base URL for a given `href` attribute by checking if it is relative or absolute.
    ///
    /// If the `href` is relative, it uses the `<base>` tag in the provided HTML head (if available)
    /// to determine the correct base URL. If no `<base>` tag is present, it uses the provided `url` as the base.
    ///
    /// - Parameters:
    ///   - head: The `<head>` element of the HTML document. This is where the method looks for a `<base>` tag.
    ///   - url: The base URL to use if no `<base>` tag is found, or to resolve relative URLs.
    ///
    /// - Returns: A fully resolved `URL` object if successful, or `nil` if the `href` could not be resolved.
    ///
    /// - Example:
    ///   ```swift
    ///   let href = "/images/favicon.ico"
    ///   let baseUrl = href.baseUrl(from: htmlHead, from: URL(string: "https://example.com")!)
    ///   // baseUrl will resolve to "https://example.com/images/favicon.ico"
    ///   ```
    ///   
    func baseUrl(from head: SwiftSoup.Element, from url: URL) -> URL? {
        // If we don't have a http or https prepended to our href, prepend our base domain
        // If we don't have a http or https prepended to our href, prepend our base domain
        if Regex.testForHttpsOrHttp(input: self) == false {
            let baseRef = {() -> URL in
                // Try and get the base URL from a HTML tag if we can
                if let baseRef = try? head.getElementsByTag("base").attr("href"),
                   let baseRefUrl = URL(string: baseRef, relativeTo: url) {
                    return baseRefUrl
                }

                // We couldn't get the base URL from a HTML tag, so we'll use the base URL that we have on hand
                else {
                    return url
                }
            }

            return URL(string: self, relativeTo: baseRef())
        } else {
            // Our href is a proper URL, nevermind
            return URL(string: self)
        }
    }

}
