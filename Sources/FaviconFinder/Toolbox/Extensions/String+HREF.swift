//
//  String+HREF.swift
//  
//
//  Created by William Lumley on 11/2/2024.
//

import Foundation
import SwiftSoup

extension String {

    /// Determines the URL that our favicon will come from with the provided `href`.
    ///
    /// If the provided `url` property of this class is relative, we will use the HTML Head given and
    /// extrapolates the base URL from it.
    ///
    /// - Parameter head: The head element of the HTML we've extracted.
    /// - Returns: The URL that our Favicon will have come from if we use this href.
    ///
    func baseUrl(from head: SwiftSoup.Element, from url: URL) -> URL? {
        // If we don't have a http or https prepended to our href, prepend our base domain
        // If we don't have a http or https prepended to our href, prepend our base domain
        if Regex.testForHttpsOrHttp(input: self) == false {
            let baseRef = {() -> URL in
                // Try and get the base URL from a HTML tag if we can
                if let baseRef = try? head.getElementsByTag("base").attr("href"), let baseRefUrl = URL(string: baseRef, relativeTo: url) {
                    return baseRefUrl
                }
                
                // We couldn't get the base URL from a HTML tag, so we'll use the base URL that we have on hand
                else {
                    return url
                }
            }

            return URL(string: self, relativeTo: baseRef())
        }
        
        // Our href is a proper URL, nevermind
        else {
            return URL(string: self)
        }
    }

}
