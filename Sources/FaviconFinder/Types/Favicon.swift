//
//  Favicon.swift
//  FaviconFinder
//
//  Created by William Lumley on 26/5/21.
//

import Foundation

public struct Favicon {

    // MARK: - Properties

    /// The actual image. Can be `nil` if  the download fails
    public let image: FaviconImage?

    /// The url of the .ico or HTML page, of where the favicon was found
    public let url: FaviconURL

    // MARK: - Lifecycle

    /// Upon instantiation, we will attempt to download the image at the provided location
    ///
    /// - Parameter url: The `FaviconURL` that has the location to our image data
    public init(url: FaviconURL) async throws {
        self.url = url

        // Download the image from the URL provided, and store the data and image
        let data = try await FaviconURLSession.dataTask(with: url.source).data
        guard let image = try? FaviconImage(data: data) else {
            throw FaviconError.invalidImage
        }

        self.image = image
    }
}
