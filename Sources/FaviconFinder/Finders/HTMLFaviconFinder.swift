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

    struct HtmlReference {
        let rel: String
        let href: String
        let sizeTag: String?

        let baseURL: URL
        let format: FaviconFormatType
    }

    struct OpenGraphicReference {
        let type: String
        let content: String
        let size: FaviconSize?

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
        let html: Document

        if let prefetchedHTML = configuration.prefetchedHTML {
            html = prefetchedHTML
        } else {
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
            html = try SwiftSoup.parse(htmlStr)
        }

        // Get just the head of our HTML document
        guard let head = html.head() else {
            throw FaviconError.failedToParseHtmlHead
        }

        // Get all the "link" favicon tags from our head
        let links = try self.links(from: head)

        // Create FaviconURLs from our links
        var faviconURLs = links.map {
            FaviconURL(
                source: $0.baseURL,
                format: $0.format,
                sourceType: .html,
                htmlSizeTag: $0.sizeTag
            )
        }

        // Create FaviconURLs from our metas
        let metas = try self.metas(from: head)
        faviconURLs += metas.map {
            FaviconURL(
                source: $0.baseURL,
                format: $0.format,
                sourceType: .html,
                size: $0.size
            )
        }

        if faviconURLs.isEmpty {
            throw FaviconError.failedToFindFavicon
        }

        return faviconURLs
    }

}

// MARK: - Private

private extension HTMLFaviconFinder {

    /// Will extrapolate all the "link" elements from the provided HTML header element, and
    /// return the ones that correlate to favicon imgaes
    ///
    /// - parameter htmlHead: Our HTML header elelment
    /// - returns: An array of "link" elements, formatted in our internal `Reference` struct
    ///
    func links(from htmlHead: Element) throws -> [HtmlReference] {
        // Where we're going to store our HTML favicons
        var links = [HtmlReference]()

        // Iterate over every 'link' tag that's in the head document, and collect them
        for link in try htmlHead.select("link") {
            let rel = try link.attr("rel")
            let href = try link.attr("href")
            let sizeTag = try link.attr("sizes")

            // If this link's "rel" is something other than an accepted image
            // format type, dismiss it
            guard FaviconFormatType(rawValue: rel) != nil else {
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

    /// Will extrapolate all the "meta" elements from the provided HTML header element, and
    /// return the ones that correlate to favicon imgaes
    ///
    /// - parameter htmlHead: Our HTML header elelment
    /// - returns: An array of "link" elements, formatted in our internal `Reference` struct
    ///
    func metas(from htmlHead: Element) throws -> [OpenGraphicReference] {
        // Where we're going to store our HTML favicons
        var metas = [OpenGraphicReference]()

        // Iterate over every 'link' tag that's in the head document, and collect them
        for meta in try htmlHead.select("meta") {
            var property = try meta.attr("property")
            let content = try meta.attr("content")

            // If this link's "property" is something other than an accepted image
            // format type, dismiss it
            if FaviconFormatType(rawValue: property) == nil {

                // Okay so "property" gave us nothing, let's try name
                property = try meta.attr("name")
                if FaviconFormatType(rawValue: property) == nil {
                    // Still nothing, onto the next one
                    continue
                }
            }

            // Get the base URL from the href
            guard let baseURL = content.baseUrl(from: htmlHead, from: self.url) else {
                continue
            }

            // Get the format type in our own internal type
            guard let format = FaviconFormatType(rawValue: property) else {
                continue
            }

            // Pull out the size if we can
            var size: FaviconSize?
            if
                let width = content.valueOfQueryParam("width"),
                let height = content.valueOfQueryParam("height") {
                size = .init(widthStr: width, heightStr: height)
            }

            // Add the potential favicon type to our links array
            metas.append(
                .init(
                    type: property,
                    content: content,
                    size: size,
                    baseURL: baseURL,
                    format: format
                )
            )
        }

        return metas
    }

}
