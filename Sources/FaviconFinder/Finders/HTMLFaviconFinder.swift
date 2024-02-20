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
        let sizeTag: String?

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
        let response = try await FaviconURLSession.dataTask(
            with: self.url,
            checkForMetaRefreshRedirect: self.configuration.checkForMetaRefreshRedirect
        )

        let data = response.data

        // Make sure we can parse the response into a string
        guard let htmlStr = String(data: data, encoding: response.textEncoding) else {
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

        let faviconURLs = links.map {
            FaviconURL(source: $0.baseURL, format: $0.format, sourceType: .html, sizeTag: $0.sizeTag)
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
            let sizeTag = try link.attr("sizes")

            // If this link's "rel" is something other than an accepted image format type, dismiss it
            guard (FaviconFormatType(rawValue: rel) != nil) else {
                continue
            }

            // Get the base URL from the href
            guard let baseURL = href.baseUrl(from: htmlHead, from: self.url) else {
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
                    sizeTag: sizeTag,
                    baseURL: baseURL,
                    format: format
                )
            )
        }

        return links
    }

}
