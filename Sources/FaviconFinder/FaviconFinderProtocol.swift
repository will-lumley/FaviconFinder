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

    /// The object that contains all our configuration data
    var configuration: FaviconFinder.Configuration { get set }

    /// The preferred type of Favicon. This is dependant on type.
    /// For example, in`ICOFaviconFinder` the `preferredType` is a filename, for `WebApplicationManifestFaviconFinder` the
    /// `preferredType` is the desired key in the JSON file, etc.
    var preferredType: String { get }

    init(url: URL, configuration: FaviconFinder.Configuration)

    func find() async throws -> [FaviconURL]

}

