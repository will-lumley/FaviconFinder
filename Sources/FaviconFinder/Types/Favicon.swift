//
//  Favicon.swift
//  FaviconFinder
//
//  Created by William Lumley on 26/5/21.
//

import Foundation

public struct Favicon: Sendable {

    // MARK: - Properties

    /// The actual image. Can be `nil` if  the download fails
    public let image: FaviconImage?

    /// The url of the .ico or HTML page, of where the favicon was found
    public let url: FaviconURL

    // MARK: - Lifecycle

    /// Upon instantiation, we will attempt to download the image at the provided location
    ///
    /// - parameter url: The `FaviconURL` that has the location to our image data
    /// 
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

// MARK: - [Favicon]

/// Something important to note is that these functions require the `FaviconImage` to be downloaded (using the
/// `download()` function first so comparison can take place.
/// This is generally not advised unless you are in a situation where the size isn't indicated via HTML tags or WMAF
/// tags.
///
///
public extension Array where Element == Favicon {

    /// Will pull the first `Favicon` from the array
    ///
    /// - Important: Why not jus use the `.first` computed variable that comes
    /// with arrays? Because that variable returns `nil` if the array is empty. Throughout
    /// this project, we throw an error if something has gone wrong rather than silently fail. To
    /// ensure that consistency can be kept, this function is provided to developers and an
    /// error will be thrown if the array is empty.
    ///
    /// - returns: The first `Favicon` in this array
    ///
    func first() throws -> Favicon {
        guard let first = self.first else {
            throw FaviconError.failedToFindFavicon
        }

        return first
    }

    /// Will pull the `Favicon` from the array that has the largest image size
    ///
    /// - returns: The `Favicon` that has the largest image
    ///
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
    /// - returns: The `Favicon` that has the smallest image
    ///
    func smallest() throws -> Favicon {

        // Find the Favicon with the smallest image
        let first = try self.first()
        let smallestImage = try self.reduce(first) { current, next in
            guard let currentImage = current.image, let nextImage = next.image else {
                throw FaviconError.faviconImageIsNotDownloaded
            }

            if currentImage.size < nextImage.size {
                return current
            } else {
                return next
            }
        }

        return smallestImage
    }

}
