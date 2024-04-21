//
//  FaviconFinder+Configuration.swift
//
//
//  Created by William Lumley on 8/2/2024.
//

import Foundation
import SwiftSoup

public extension FaviconFinder {

    struct Configuration {

        // MARK: - Properties

        /// Which download type our user would prefer to use
        public let preferredSource: FaviconSourceType

        /// Which preferences the user has for each source type
        public let preferences: [FaviconSourceType: String]

        /// Indicates if we should check for a meta-refresh-redirect tag in the HTML header
        public let checkForMetaRefreshRedirect: Bool

        public let prefetchedHTML: Document?

        // MARK: - Lifecycle

        public init(
            preferredSource: FaviconSourceType = .html,
            preferences: [FaviconSourceType : String] = [:],
            checkForMetaRefreshRedirect: Bool = false,
            prefetchedHTML: Document? = nil
        ) {
            self.preferredSource = preferredSource
            self.preferences = preferences
            self.checkForMetaRefreshRedirect = checkForMetaRefreshRedirect
            self.prefetchedHTML = prefetchedHTML
        }
    }

}

public extension FaviconFinder.Configuration {

    static var defaultConfiguration: FaviconFinder.Configuration {
        .init()
    }

}
