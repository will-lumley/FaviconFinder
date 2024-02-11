//
//  HTMLFaviconFinder.swift
//  Pods
//
//  Created by William Lumley on 26/5/21.
//

import Foundation

#if canImport(SwiftSoup)
import SwiftSoup
#endif

class WebApplicationManifestFaviconFinder: FaviconFinderProtocol {

    // MARK: - Types

    struct ManifestFileReference {
        let baseURL: URL
        let rel: String
        let href: String
    }

    // MARK: - Properties

    var url: URL
    var configuration: FaviconFinder.Configuration
    
    var preferredType: String {
        self.configuration.preferences[.webApplicationManifestFile] ?? "manifest"
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
        let rawResponse = response.rawResponse

        // Make sure we can parse the response into a string
        guard let htmlStr = String(data: data, encoding: rawResponse.encoding) else {
            throw FaviconError.failedToParseHTML
        }

        // Turn our HTML string as an XML document we can check out
        let html = try SwiftSoup.parse(htmlStr)

        // Get just the head of our HTML document
        guard let head = html.head() else {
            throw FaviconError.failedToParseHtmlHead
        }

        // Get a hold of a reference to our Manifest File
        guard let manifestFileReference = try self.manifestFileReference(from: head) else {
            throw FaviconError.failedToFindWebApplicationManifestFile
        }
        
        // Download the manifest file
        let manifestData = try await self.downloadManifestFile(with: manifestFileReference)

        // Grab our "icons" data
        guard let rawIcons = manifestData["icons"] as? [Dictionary<String, String>] else {
            throw FaviconError.webApplicationManifestFileConainedNoIcons
        }

        // And turn it into something we can work with
        let faviconURLs = rawIcons.compactMap { rawIcon -> FaviconURL? in
            guard let rawFormat = rawIcon["src"] else { return nil }
            guard let format = FaviconFormatType(rawValue: rawFormat) else { return nil }
            guard let sizeTag = rawIcon["sizes"] else { return nil }

            let source = self.url.appendingPathComponent(rawFormat)

            return FaviconURL(
                source: source,
                format: format,
                sourceType: .webApplicationManifestFile,
                sizeTag: sizeTag
            )
        }

        return faviconURLs
    }

}

// MARK: - Private

private extension WebApplicationManifestFaviconFinder {

    /// Will iterate through' all the "link" elements from the provided HTML header element, and
    /// return the one that has the "rel" as "manifest"
    ///
    /// - Throws: Throws an error if there is an issue iterating through the HTML header
    /// - Parameter htmlHead: Our HTML header elelment
    /// - Returns: A `ManifestFileReference` struct containing the data contained in the "manifest" tag
    ///
    func manifestFileReference(from htmlHead: Element) throws -> ManifestFileReference? {
        let manifestFileAttr = try htmlHead.select("link").first {
            try $0.attr("rel") == self.preferredType
        }

        guard let manifestFileAttr else { return nil }
        let rel = try manifestFileAttr.attr("rel")
        let href = try manifestFileAttr.attr("href")
        guard let baseURL = href.baseUrl(from: htmlHead, from: self.url) else { return nil }

        return ManifestFileReference(baseURL: baseURL, rel: rel, href: href)
    }

    /// Fetches and parses the manifest file from the reference provided
    ///
    /// - Parameter manifestFileReference: The now-native data from our HTML head that contains the manifest file data
    /// - Returns: A dictionary containing the key/value data contained in the manifest file
    ///
    func downloadManifestFile(with reference: ManifestFileReference) async throws -> Dictionary<String, Any> {
        let response = try await URLSession.shared.data(from: reference.baseURL)

        do {
            guard let manifestData = try JSONSerialization.jsonObject(with: response.0, options: .allowFragments) as? [String: Any] else {
                throw FaviconError.failedToDownloadWebApplicationManifestFile
            }

            return manifestData
        }
        catch {
            throw FaviconError.failedToParseWebApplicationManifestFile
        }
    }

}
