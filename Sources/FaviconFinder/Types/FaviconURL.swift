//
//  FaviconURL.swift
//  Pods
//
//  Created by William Lumley on 26/5/21.
//

import Foundation

public struct FaviconURL: Equatable, Sendable {

    // MARK: - Properties

    /// The url of the .ico or HTML page, of where the favicon was found
    public let source: URL

    /// The type of favicon we extracted
    public let format: FaviconFormatType

    /// The source type of the favicon we extracted
    public let sourceType: FaviconSourceType

    /// If the icon metadata tells us the size, we'll store it here
    public let size: FaviconSize?

    // MARK: - Lifecycle

    public init(
        source: URL,
        format: FaviconFormatType,
        sourceType: FaviconSourceType,
        size: FaviconSize? = nil
    ) {
        self.source = source
        self.format = format
        self.sourceType = sourceType
        self.size = size
    }

    public init(
        source: URL,
        format: FaviconFormatType,
        sourceType: FaviconSourceType,
        htmlSizeTag: String?
    ) {
        self.source = source
        self.format = format
        self.sourceType = sourceType
        self.size = Self.inferredSize(from: htmlSizeTag)
    }

}

// MARK: - Public

public extension FaviconURL {

    /// Creates a `Favicon` instance with this `FaviconURL` information, which
    /// will kickstart a download of the relevant image data, and then returns this data
    /// and other relevant metadata in the `Favicon` struct.
    ///
    /// - returns: A `Favicon`, that contains the downloaded image data.
    ///
    func download() async throws -> Favicon {
        guard let favicon = try? await Favicon(url: self) else {
            throw FaviconError.failedToDownloadFavicon
        }

        return favicon
    }

}

// MARK: - Private

private extension FaviconURL {

    /// Using the `sizeTag` this will return the indicated size of the image located at the URL.
    /// If `sizeTag` is `nil`, then `nil` will be returned.
    ///
    /// - parameter htmlTag: A string from a HTML header file that represents the size. Formated in the following
    /// way: 120x120
    /// - returns: The Size that is indicated in the `sizeTag`
    ///
    static func inferredSize(from htmlTag: String?) -> FaviconSize? {
        guard let htmlTag else {
            return nil
        }

        // Split the size tag components into their individual numbers
        let components = htmlTag.split(separator: "x")

        // Make sure we only got two components, or something has gone wrong
        guard components.count == 2 else {
            return nil
        }

        // Grab the sizes as strings
        let widthStr  = components[0]
        let heightStr = components[1]

        // Let's convert those strings into doubles
        guard let width = Double(widthStr), let height = Double(heightStr) else {
            return nil
        }

        // Wrap it up in a pretty ~bow~ Size
        return .init(width: width, height: height)
    }

}

// MARK: - [FaviconURL]

public extension Array where Element == FaviconURL {

    /// Will iterate over each `FaviconURL` and analyse the `inferredSize`, and returns
    /// the largest one.
    ///
    /// Notably, calling `largest()` on an array of `FaviconURL` instead of on an array of
    /// `Favicon` means you can extrapolate the largest image without having to download all of them.
    /// This comes with the drawbacks of
    ///     1. Only being able to use this function appropriately if the source has set the sizeTags, either in the
    ///       HTML or the WebApplicationManifestFile.
    ///     2. Not being 100% certain, as the size in the sizeTags and the actual true size may be different due
    ///       to the source being configured incorrectly.
    ///
    /// However there are plently of use cases where these drawbacks are worth it to get the largest image without
    /// having to download them all, so here we are.
    ///
    /// - returns: A `FaviconURL` from the array of `FaviconURL`s that we deem to be the largest.
    ///
    func largest() async throws -> FaviconURL {
        let largestFavicon = self
            // Return true  if `a` is less than `b`
            // Return false if `b` is less than `a`
            .max { faviconA, faviconB in
                guard let dimensionA = faviconA.size?.dimension else {
                    return true
                }
                guard let dimensionB = faviconB.size?.dimension else {
                    return false
                }

                return dimensionA < dimensionB
            }

        guard let largestFavicon else {
            throw FaviconError.failedToFindFavicon
        }
        return largestFavicon
    }

    /// Will iterate over each `FaviconURL` and analyse the `inferredSize`, and returns
    /// the smallest one.
    ///
    /// Notably, calling `smallest()` on an array of `FaviconURL` instead of on an array of
    /// `Favicon` means you can extrapolate the smallest image without having to download all of them.
    /// This comes with the drawbacks of
    ///     1. Only being able to use this function appropriately if the source has set the sizeTags, either in the
    ///       HTML or the WebApplicationManifestFile.
    ///     2. Not being 100% certain, as the size in the sizeTags and the actual true size may be different due
    ///       to the source being configured incorrectly.
    ///
    /// However there are plently of use cases where these drawbacks are worth it to get the smallest image without
    /// having to download them all, so here we are.
    ///
    /// - returns: A `FaviconURL` from the array of `FaviconURL`s that we deem to be the smallest.
    ///
    func smallest() async throws -> FaviconURL {
        let smallestFavicon = self
            // Return true  if `a` is less than `b`
            // Return false if `b` is less than `a`
            .max { faviconA, faviconB in
                guard let dimensionA = faviconA.size?.dimension else {
                    return true
                }
                guard let dimensionB = faviconB.size?.dimension else {
                    return false
                }

                return dimensionA > dimensionB
            }

        guard let smallestFavicon else {
            throw FaviconError.failedToFindFavicon
        }
        return smallestFavicon

    }

    /// Will iterate over each FaviconURL in our array, and initiate
    /// a `Favicon` instance after downloading the image data
    /// at the source specified by the FaviconURL.
    ///
    /// - returns: An array of `Favicon`, each containing the downloaded image data.
    ///
    func download() async throws -> [Favicon] {
        var favicons = [Favicon]()
        for url in self {
            guard let favicon = try? await Favicon(url: url) else {
                continue
            }
            favicons.append(favicon)
        }

        return favicons
    }

}
