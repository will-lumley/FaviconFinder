//
//  Favicon.swift
//  FaviconFinder
//
//  Created by William Lumley on 26/5/21.
//

import Foundation

/// `Favicon` represents the downloaded favicon image along with metadata.
///
/// This struct encapsulates the favicon's image and the URL from which it was retrieved.
/// When initialized, it automatically downloads the favicon from the provided `FaviconURL`.
///
/// - Properties:
///   - `image`: The downloaded favicon image, which may be `nil` if the download fails.
///   - `url`: The URL from which the favicon was retrieved, encapsulated in a `FaviconURL`.
///
/// - Lifecycle:
///   - `init(url: FaviconURL)`: Initializes the `Favicon` by downloading the image at the given `FaviconURL`.
///
/// - Throws: Throws `FaviconError.invalidImage` if the image cannot be downloaded or parsed
///
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

/// Extension on `[Favicon]` providing additional utility functions to fetch
/// the first, largest, or smallest favicon from an array of `Favicon` objects.
///
/// - Important: These functions require that the `FaviconImage` has been downloaded
/// before comparison can be done. If the size is indicated by HTML tags or WMAF,
/// downloading may not be necessary.
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
    /// - Returns: The first `Favicon` in this array
    ///
    func first() throws -> Favicon {
        guard let first = self.first else {
            throw FaviconError.failedToFindFavicon
        }

        return first
    }

    /// Returns the `Favicon` with the largest image in the array.
    ///
    /// - Throws: `FaviconError.faviconImageIsNotDownloaded` if any `Favicon` in the array has no image.
    /// - Returns: The `Favicon` with the largest image size.
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

    /// Returns the `Favicon` with the smallest image in the array.
    ///
    /// - Throws: `FaviconError.faviconImageIsNotDownloaded` if any `Favicon` in the array has no image.
    /// - Returns: The `Favicon` with the smallest image size.
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
