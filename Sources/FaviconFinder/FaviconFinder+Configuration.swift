//
//  FaviconFinder+Configuration.swift
//
//
//  Created by William Lumley on 8/2/2024.
//

import Foundation
import SwiftSoup

public extension FaviconFinder {

    struct Configuration: @unchecked Sendable {

        // MARK: - Properties

        /// Which download type our user would prefer to use
        public let preferredSource: FaviconSourceType

        /// Which preferences the user has for each source type
        public let preferences: [FaviconSourceType: String]

        /// Indicates if we should check for a meta-refresh-redirect tag in the HTML header
        public let checkForMetaRefreshRedirect: Bool

        /// The HTTP headers we'll pass along to our HTTP request
        public let httpHeaders: [String: String?]?

        /// An optional prefetched HTML document that you can pass if you'd rather not FaviconFinder
        /// do the HTML document downloading, or you have a local document.
        public let prefetchedHTML: Document?

        // MARK: - Lifecycle

        public init(
            preferredSource: FaviconSourceType = .html,
            preferences: [FaviconSourceType: String] = [:],
            checkForMetaRefreshRedirect: Bool = false,
            prefetchedHTML: Document? = nil,
            httpHeaders: [String: String?]? = nil
        ) {
            self.preferredSource = preferredSource
            self.preferences = preferences
            self.checkForMetaRefreshRedirect = checkForMetaRefreshRedirect
            self.prefetchedHTML = prefetchedHTML
            self.httpHeaders = httpHeaders
        }
    }

}

public extension FaviconFinder.Configuration {

    static var defaultConfiguration: FaviconFinder.Configuration {
        .init()
    }

}
