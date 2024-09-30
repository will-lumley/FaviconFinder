//
//  FaviconFinderProtocol.swift
//  Pods
//
//  Created by William Lumley on 26/5/21.
//

import Foundation

/// `FaviconFinderProtocol` defines the blueprint for any class responsible for
/// finding favicons from a given website. Classes conforming to this protocol must
/// implement the logic to extract favicon URLs and support various configurations
/// and preferences for fetching favicons.
///
protocol FaviconFinderProtocol {

    /// The URL of the website from which the favicon is being queried.
    ///
    /// This URL represents the base location of the website that we are attempting to retrieve
    /// the favicon from.
    var url: URL { get set }

    /// The configuration object containing the user's preferences for finding favicons.
    ///
    /// The `configuration` object encapsulates user preferences, such as which sources
    /// to prioritize, custom headers, and meta-refresh handling.
    var configuration: FaviconFinder.Configuration { get set }

    /// The preferred type of favicon to search for, based on the specific finder type.
    ///
    /// This value varies depending on the implementation. For instance, in `ICOFaviconFinder`,
    /// the preferred type might be a specific file name, such
    /// as `favicon.ico`. In `WebApplicationManifestFaviconFinder`, the `preferredType` could
    /// be the key in a JSON manifest file.
    var preferredType: String { get }

    /// Initializes a new instance of the favicon finder.
    ///
    /// - Parameters:
    ///   - url: The URL of the website from which to query the favicon.
    ///   - configuration: The configuration object containing user preferences for fetching favicons.
    init(url: URL, configuration: FaviconFinder.Configuration)

    /// Attempts to find all available favicons for the website.
    ///
    /// The function will attempt to fetch the favicon URLs based on the finder type's specific logic
    /// and return an array of `FaviconURL`s representing the found favicons.
    ///
    /// - Returns: An array of `FaviconURL`s that represent the favicons available for the website.
    /// - Throws: An error if the favicons could not be found.
    /// 
    func find() async throws -> [FaviconURL]

}
