//
//  FaviconFinder.swift
//  FaviconFinder
//
//  Created by William Lumley on 16/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

import Foundation

public final class FaviconFinder: @unchecked Sendable {

    // MARK: - Properties

    /// The URL of the site we're trying to extract the Favicon from
    private let url: URL

    /// Our configuration object
    private let configuration: FaviconFinder.Configuration

    /// The current task for fetching favicon URLs
    private var currentTask: Task<[FaviconURL], Error>?

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
        // Cancel any previous task
        self.cancel()

        // Copy configuration and url for outside of the Task
        let config = self.configuration
        let url = self.url

        // Create a new task for fetching favicon URLs
        self.currentTask = Task {
            // All of the sources we'll use to search for our favicon
            // Get the users preferred source and move it to the front of the queue
            let preferredSource = config.preferredSource

            // If this is a mock run, just do that
            if preferredSource == .mock {
                let finder = preferredSource.finder(url: url, configuration: config)
                return try await finder.find()
            }

            let sources = FaviconSourceType.allCases.movingElementToFront(preferredSource)

            // Iterate through each source, trying to find the favicon
            // in each source until we find it.
            for source in sources {
                print("Trying with [\(source)] source")
                do {
                    let finder = source.finder(url: url, configuration: config)
                    let faviconURLs = try await finder.find()
                    return faviconURLs
                } catch is CancellationError {
                    // The user has cancelled this, let's bubble this up
                    throw CancellationError()
                } catch let error as NSError {
                    // Check if the error is a URL cancellation error
                    if error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
                        // Map this to Swift's `CancellationError`
                        throw CancellationError()
                    } else {
                        print("Failed to find Favicon [\(error)]. Trying next source type.")
                    }
                } catch {
                    print("Failed to find Favicon [\(error)]. Trying next source type.")
                }
            }

            throw FaviconError.failedToFindFavicon
        }

        // Await the result of the current task
        guard let currentTask else {
            throw FaviconError.other
        }
        return try await currentTask.value
    }

    /// Cancels the ongoing favicon fetch task, if any.
    func cancel() {
        self.currentTask?.cancel()
    }

}

// MARK: - Private

private extension FaviconFinder {

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
                guard let sizeA = faviconA.inferredSize else {
                    return true
                }
                guard let sizeB = faviconB.inferredSize else {
                    return false
                }

                let sizeAValue = sizeA.width * sizeA.height
                let sizeBValue = sizeB.width * sizeB.height

                return sizeAValue < sizeBValue
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
                guard let sizeA = faviconA.inferredSize else {
                    return true
                }
                guard let sizeB = faviconB.inferredSize else {
                    return false
                }

                let sizeAValue = sizeA.width * sizeA.height
                let sizeBValue = sizeB.width * sizeB.height

                return sizeAValue > sizeBValue
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
