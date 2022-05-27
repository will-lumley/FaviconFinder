//
//  FaviconFinderProtocol.swift
//  Pods
//
//  Created by William Lumley on 26/5/21.
//

import Foundation

protocol FaviconFinderProtocol {

    /// The URL of the website we're querying the Favicon for
    var url: URL { get set }

    /// Whether or not we this Finder will log information to the console
    var logEnabled: Bool { get set }

    /// The preferred type of Favicon. This is dependant on type.
    /// For example, `ICOFaviconFinder` the `preferredType` is a filename, for `WebApplicationManifestFaviconFinder` the
    /// `preferredType` is the desired key in the JSON file, etc.
    var preferredType: String { get set }

    /// A string representation of the class name. Used for logging purposes.
    var description: String { get }

    /// Indicates if we should check for a meta-refresh-redirect tag in the HTML header
    var checkForMetaRefreshRedirect: Bool { get }

    /// An instance of the object we direct logging through.
    var logger: Logger? { get }

    init(url: URL, preferredType: String?, checkForMetaRefreshRedirect: Bool, logEnabled: Bool)
    func search() async throws -> FaviconURL

}

