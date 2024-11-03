//
//  FaviconFinder+Configuration.swift
//
//
//  Created by William Lumley on 8/2/2024.
//

import Foundation
import SwiftSoup

public extension FaviconFinder {

    /// The `Configuration` struct contains settings and preferences for the `FaviconFinder`.
    /// It allows users to customize how the favicon is retrieved, including preferences for specific
    /// sources, custom HTTP headers, and more.
    ///
    struct Configuration: @unchecked Sendable {

        // MARK: - Properties

        /// The user's preferred source type for fetching the favicon.
        ///
        /// This can be set to prioritize fetching from a specific source
        /// such as `.html`, `.ico`, or `.webApplicationManifestFile`.
        /// Defaults to `.html`.
        ///
        public let preferredSource: FaviconSourceType

        /// Preferences for specific favicon source types.
        ///
        /// This allows users to specify preferences for each source type.
        /// For example, a preference could define the desired file or link type for each source.
        public let preferences: [FaviconSourceType: String]

        /// Determines whether or not the HTML should be checked for a `meta-refresh-redirect` tag.
        ///
        /// When this is enabled, `FaviconFinder` will inspect the HTML header for meta-refresh redirects
        /// and follow the redirect if found.
        /// Defaults to `false`.
        public let checkForMetaRefreshRedirect: Bool

        /// A prefetched HTML document that can be passed in if the user already has the HTML.
        ///
        /// If set, `FaviconFinder` will use this document instead of downloading the HTML
        /// from the specified URL.
        /// Useful when working with local HTML documents or when the HTML is already available in memory.
        public let prefetchedHTML: Document?

        /// HTTP headers to pass along with the HTTP request when fetching the favicon.
        ///
        /// This allows users to specify custom HTTP headers, such as user-agent or authorization tokens.
        public let httpHeaders: [String: String?]?

        /// Determines whether we'll include a websites header image as a valid image to fetch
        public let acceptHeaderImage: Bool

        // MARK: - Lifecycle

        /// Initializes a new configuration object.
        ///
        /// - Parameters:
        ///   - preferredSource: The preferred source for fetching the favicon. Defaults to `.html`.
        ///   - preferences: A dictionary mapping each source type to a specific preference.
        ///   Defaults to an empty dictionary.
        ///   - checkForMetaRefreshRedirect: A boolean indicating whether to check for
        ///   meta-refresh-redirect tags. Defaults to `false`.
        ///   - prefetchedHTML: A pre-downloaded HTML document to use instead of fetching HTML from the
        ///   network. Defaults to `nil`.
        ///   - httpHeaders: HTTP headers to use when making requests. Defaults to `nil`.
        ///   - acceptHeaderImage: Determines whether we'll include a websites header image as a valid image to fetch.
        ///
        public init(
            preferredSource: FaviconSourceType = .html,
            preferences: [FaviconSourceType: String] = [:],
            checkForMetaRefreshRedirect: Bool = false,
            prefetchedHTML: Document? = nil,
            httpHeaders: [String: String?]? = nil,
            acceptHeaderImage: Bool = false
        ) {
            self.preferredSource = preferredSource
            self.preferences = preferences
            self.checkForMetaRefreshRedirect = checkForMetaRefreshRedirect
            self.prefetchedHTML = prefetchedHTML
            self.httpHeaders = httpHeaders
            self.acceptHeaderImage = acceptHeaderImage
        }
    }

}

public extension FaviconFinder.Configuration {

    /// Provides the default configuration for `FaviconFinder`.
    ///
    /// This configuration uses `.html` as the preferred source type, with no additional preferences,
    /// meta-refresh checking disabled, and no pre-downloaded HTML.
    /// 
    static var defaultConfiguration: FaviconFinder.Configuration {
        .init()
    }

}
