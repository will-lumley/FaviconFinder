//
//  FaviconFinder.swift
//  FaviconFinder
//
//  Created by William Lumley on 16/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

import Foundation

public class FaviconFinder {
    
    // MARK: - Properties
    
    /// The URL of the site we're trying to extract the Favicon from
    private let url: URL
    
    /// Our configuration object
    private let configuration: FaviconFinder.Configuration
    
    // MARK: - Lifecycle
    
    public init(url: URL, configuration: FaviconFinder.Configuration = .defaultConfiguration) {
        self.url = url
        self.configuration = configuration
    }

}

// MARK: - Public

public extension FaviconFinder {

    /// Will iterate through each of the source types we have available to us, and
    /// search for the websites favicon through there.
    ///
    /// - Important: If the user has set a source preference in the Configuration, then
    /// that source will be moved to the front of the queue in the hopes the preference can be
    /// made.
    /// - Returns: An array of FaviconURLs that contain the location of all the users favicons
    func fetchFaviconURLs() async throws -> [FaviconURL] {
        // All of the sources we'll use to search for our favicon
        var sources = FaviconSourceType.allCases

        // Get the users preferred source and move it to the front of the queue
        sources.moveElementToFront(self.configuration.preferredSource)

        // Iterate through each source, trying to find the favicon
        // in each source until we find it.
        for source in sources {
            do {
                let faviconURLs = try await self.fetchFavicon(with: source)
                if faviconURLs.count > 0 {
                    return faviconURLs
                }
            } catch {
                print("Failed to find Favicon [\(error)]. Trying next source type.")
            }
        }

        throw FaviconError.failedToFindFavicon
    }

}

// MARK: - Private

private extension FaviconFinder {

    /// Will use the provided `source` to find the websites Favicon.
    ///
    /// - Important: Will throw a `FaviconError` if an issue is encountered, or none is found.
    ///
    /// - Parameter source: The source that we should use to find the Favicon
    /// - Returns: An array of FaviconURLs that contain the location of all the users favicons
    func fetchFavicon(with source: FaviconSourceType) async throws -> [FaviconURL] {
        // Setup the download, and get it to search for the URL
        let finder = source.finder(
            url: self.url,
            configuration: self.configuration
        )
        return try await finder.find()
    }

}

// MARK: - [FaviconURL]

public extension Array where Element == FaviconURL {

    /// Will iterate over each FaviconURL in our array, and initiate
    /// a `Favicon` instance after downloading the image data
    /// at the source specified by the FaviconURL.
    ///
    /// - Returns: An array of `Favicon`, each containing the downloaded image data.
    func download() async throws -> [Favicon] {
        var favicons = [Favicon]()
        for url in self {
            favicons.append(
                try await Favicon(url: url)
            )
        }

        return favicons
    }

}

// MARK: - [Favicon]

public extension Array where Element == Favicon {

    /// Will pull the first `Favicon` from the array
    ///
    /// - Important: Why not jus use the `.first` computed variable that comes
    /// with arrays? Because that variable returns `nil` if the array is empty. Throughout
    /// this project, we throw an error if something has gone wrong rather than silently fail. To
    /// ensure that consistency can be kept, this function is provided to developers and an
    /// error will be thrown if the array is empty.
    ///
    /// - Returns: The first `Favicon` in this array
    func first() throws -> Favicon {
        guard let first = self.first else {
            throw FaviconError.failedToFindFavicon
        }

        return first
    }

    /// Will pull the `Favicon` from the array that has the largest image size
    ///
    /// - Returns: The `Favicon` that has the largest image
    func largest() throws -> Favicon {

        // Find the Favicon with the largest image
        let first = try self.first()
        let largestImage = try self.reduce(first) { current, next in
            guard let currentImage = current.image, let nextImage = next.image else {
                throw FaviconError.faviconImageIsNotDownloaded
            }

            if currentImage.size > nextImage.size {
                return current
            } else {
                return next
            }
        }

        return largestImage
    }

    /// Will pull the `Favicon` from the array that has the smallest image size
    ///
    /// - Returns: The `Favicon` that has the smallest image
    func smallest() throws -> Favicon {

        // Find the Favicon with the smallest image
        let first = try self.first()
        let largestImage = try self.reduce(first) { current, next in
            guard let currentImage = current.image, let nextImage = next.image else {
                throw FaviconError.faviconImageIsNotDownloaded
            }

            if currentImage.size < nextImage.size {
                return current
            } else {
                return next
            }
        }

        return largestImage
    }

}
