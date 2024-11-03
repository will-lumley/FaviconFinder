//
//  HTMLFaviconFinder.swift
//  Pods
//
//  Created by William Lumley on 26/5/21.
//

import Foundation
import SwiftSoup

/// `HTMLFaviconFinder` is responsible for extracting favicons from an HTML document.
/// It conforms to the `FaviconFinderProtocol` and is responsible for parsing both
/// `<link>` and `<meta>` tags in the HTML head to retrieve relevant favicon data.
///
/// This class supports fetching favicons via both standard HTML `<link>` elements
/// (e.g., `<link rel="icon" href="...">`) and OpenGraph meta tags (e.g., `<meta property="og:image" content="...">`).
///
/// Use the `find()` method to start searching for favicons in an HTML document.
///
/// - Note: This class also supports handling meta-refresh redirects if enabled in the configuration.
///
final class HTMLFaviconFinder: FaviconFinderProtocol {

    // MARK: - Types

    /// A structure representing a reference to a favicon found in an HTML `<link>` tag.
    struct HtmlReference {
        let rel: String
        let href: String
        let sizeTag: String?

        let baseURL: URL
        let format: FaviconFormatType
    }

    /// A structure representing a reference to a favicon found in an OpenGraph `<meta>` tag.
    struct OpenGraphicReference {
        let type: String
        let content: String
        let size: FaviconSize?

        let baseURL: URL
        let format: FaviconFormatType
    }

    // MARK: - Properties

    /// The `URL` of the website for which the favicons are being searched.
    var url: URL

    /// Configuration options for customizing the favicon search, including preferences
    /// for which favicon types to search for and whether meta-refresh redirects should be handled.
    var configuration: FaviconFinder.Configuration

    var preferredType: String {
        self.configuration.preferences[.html] ?? FaviconFormatType.appleTouchIcon.rawValue
    }

    // MARK: - FaviconFinder

    /// Initialises a `HTMLFaviconFinder` instance.
    ///
    /// - Parameters:
    ///   - url: The URL of the website to search for favicons.
    ///   - configuration: A configuration object that contains user preferences and options.
    ///
    /// - Returns: A new `HTMLFaviconFinder` instance.
    ///
    required init(url: URL, configuration: FaviconFinder.Configuration) {
        self.url = url
        self.configuration = configuration
    }

    /// Finds favicons in the HTML document. This method looks for both
    /// `<link>` and `<meta>` tags to identify any favicons.
    ///
    /// The method checks for a prefetched HTML document in the configuration;
    /// if one isn't found, it fetches the HTML from the `url`.
    ///
    /// - Throws: `FaviconError.failedToParseHTML` if the HTML cannot be parsed.
    /// - Throws: `FaviconError.failedToFindFavicon` if no favicons are found.
    ///
    /// - Returns: An array of `FaviconURL` instances representing the found favicons.
    ///
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

    /// Parses the `<link>` elements in the provided HTML head element
    /// and returns references to any favicons found.
    ///
    /// This method identifies favicon-related `<link>` tags, such as
    /// those with `rel` attributes like `icon`, `apple-touch-icon`, etc.
    ///
    /// - Parameter htmlHead: The HTML head element to parse.
    ///
    /// - Throws: Throws an error if the parsing fails.
    ///
    /// - Returns: An array of `HtmlReference` objects that correspond to favicons found in `<link>`
    /// elements.
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

    /// Parses the `<meta>` elements in the provided HTML head element
    /// and returns references to any OpenGraph favicons found.
    ///
    /// This method identifies OpenGraph-related `<meta>` tags, such as
    /// those with `property` attributes like `og:image`.
    ///
    /// - Parameter htmlHead: The HTML head element to parse.
    ///
    /// - Throws: Throws an error if the parsing fails.
    ///
    /// - Returns: An array of `OpenGraphicReference` objects that correspond to favicons found in
    /// `<meta>` elements.
    ///
    func metas(from htmlHead: Element) throws -> [OpenGraphicReference] {
        // Where we're going to store our HTML favicons
        var metas = [OpenGraphicReference]()

        // Iterate over every 'link' tag that's in the head document, and collect them
        for meta in try htmlHead.select("meta") {
            var property = try meta.attr("property")
            let content = try meta.attr("content")

            var format = FaviconFormatType(rawValue: property)

            // If this link's "property" is something other than an accepted image
            // format type, dismiss it
            if format == nil {

                // Okay so "property" gave us nothing, let's try name
                property = try meta.attr("name")
                format = FaviconFormatType(rawValue: property)
                if format == nil {
                    // Still nothing, onto the next one
                    continue
                }
            }

            // If this is a header image AND we don't accept header images,
            // then we'll bail out
            let isHeaderImage = format == .metaOpenGraphImage
            if isHeaderImage && configuration.acceptHeaderImage == false {
                continue
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
