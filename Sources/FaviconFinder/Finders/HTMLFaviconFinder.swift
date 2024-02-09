//
//  HTMLFaviconFinder.swift
//  Pods
//
//  Created by William Lumley on 26/5/21.
//

import Foundation
import SwiftSoup

class HTMLFaviconFinder: FaviconFinderProtocol {

    // MARK: - Types
    
    struct Reference {
        let rel: String
        let href: String
        let sizes: String?

        let baseURL: URL
        let format: FaviconFormatType
    }
    
    // MARK: - Properties
    
    var url: URL
    var configuration: FaviconFinder.Configuration
    
    var preferredType: String {
        self.configuration.preferences[.html] ?? FaviconFormatType.appleTouchIcon.rawValue
    }
    
    // MARK: - FaviconFinder
    
    required init(url: URL, configuration: FaviconFinder.Configuration) {
        self.url = url
        self.configuration = configuration
    }
    
    func find() async throws -> [FaviconURL] {
        // Download the web page at our URL
        let urlResponse = try await FaviconURLRequest.dataTask(
            with: self.url,
            checkForMetaRefreshRedirect: self.configuration.checkForMetaRefreshRedirect
        )

        let data = urlResponse.data
        let response = urlResponse.response
        
        // Make sure we can parse the response into a string
        guard let htmlStr = String(data: data, encoding: response.encoding) else {
            throw FaviconError.failedToParseHTML
        }

        // Turn our HTML string as an XML document we can check out
        let html = try SwiftSoup.parse(htmlStr)

        // Get just the head of our HTML document
        guard let head = html.head() else {
            throw FaviconError.failedToParseHtmlHead
        }

        // Get all the "link" favicon tags from our head
        let links = try self.links(from: head)

        print("Links: \(links)")
        let faviconURLs = links.map {
            FaviconURL(source: $0.baseURL, format: $0.format, sourceType: .html, sizeTag: $0.sizes)
        }

        return faviconURLs
    }
    
}

// MARK: - Private

private extension HTMLFaviconFinder {

    /// Will extrapolate all the "link" elements from the provided HTML header element, and
    /// return the ones that correlate to favicon imgaes
    ///
    /// - Parameter htmlHead: Our HTML header elelment
    /// - Returns: An array of "link" elements, formatted in our internal `Reference` struct
    ///
    func links(from htmlHead: Element) throws -> [Reference] {
        // Where we're going to store our HTML favicons
        var links = [Reference]()

        // Iterate over every 'link' tag that's in the head document, and collect them
        for link in try htmlHead.select("link") {
            let rel = try link.attr("rel")
            let href = try link.attr("href")
            let sizes = try link.attr("sizes")

            // If this link's "rel" is something other than an accepted image format type, dismiss it
            guard (FaviconFormatType(rawValue: rel) != nil) else {
                continue
            }

            // Get the base URL from the href
            guard let baseURL = self.baseUrl(from: htmlHead, with: href) else {
                continue
            }

            // Get the format type in our own internal type
            guard let format = FaviconFormatType(rawValue: rel) else {
                continue
            }

            // Add the potential favicon type to our links array
            links.append(
                .init(
                    rel: rel,
                    href: href,
                    sizes: sizes,
                    baseURL: baseURL,
                    format: format
                )
            )
        }

        return links
    }

    /// Determines the URL that our favicon will come from with the provided `href`.
    ///
    /// If the provided `url` property of this class is relative, we will use the HTML Head given and
    /// extrapolates the base URL from it.
    ///
    /// - Parameter head: The head element of the HTML we've extracted.
    /// - Parameter href: The href of which this Favicon will come from.
    /// - Returns: The URL that our Favicon will have come from if we use this href.
    ///
    func baseUrl(from head: Element, with href: String) -> URL? {
        // If we don't have a http or https prepended to our href, prepend our base domain
        // If we don't have a http or https prepended to our href, prepend our base domain
        if Regex.testForHttpsOrHttp(input: href) == false {
            let baseRef = {() -> URL in
                // Try and get the base URL from a HTML tag if we can
                if let baseRef = try? head.getElementsByTag("base").attr("href"), let baseRefUrl = URL(string: baseRef, relativeTo: self.url) {
                    return baseRefUrl
                }
                
                // We couldn't get the base URL from a HTML tag, so we'll use the base URL that we have on hand
                else {
                    return self.url
                }
            }

            return URL(string: href, relativeTo: baseRef())
        }
        
        // Our href is a proper URL, nevermind
        else {
            return URL(string: href)
        }
    }

}
