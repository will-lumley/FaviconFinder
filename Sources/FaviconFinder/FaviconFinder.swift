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
    /// - important: If the user has set a source preference in the Configuration, then
    /// that source will be moved to the front of the queue in the hopes the preference can be
    /// made.
    /// - returns: An array of FaviconURLs that contain the location of all the users favicons
    ///
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
                        // print("Failed to find Favicon [\(error)]. Trying next source type.")
                    }
                } catch {
                    // print("Failed to find Favicon [\(error)]. Trying next source type.")
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
