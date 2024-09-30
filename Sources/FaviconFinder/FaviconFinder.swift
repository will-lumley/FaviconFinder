//
//  FaviconFinder.swift
//  FaviconFinder
//
//  Created by William Lumley on 16/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

import Foundation

/// `FaviconFinder` is responsible for locating favicons from a given website URL.
///
/// It manages the process of searching for favicons across different sources such as HTML, raw files,
/// and Web Application Manifest files.
public final class FaviconFinder: @unchecked Sendable {

    // MARK: - Properties

    /// The URL of the site we're trying to extract the Favicon from.
    private let url: URL

    /// Configuration object containing preferences and settings for the favicon search.
    private let configuration: FaviconFinder.Configuration

    /// The current task used to fetch favicon URLs. Can be cancelled if needed.
    private var currentTask: Task<[FaviconURL], Error>?

    // MARK: - Lifecycle

    /// Initializes a new instance of `FaviconFinder`.
    ///
    /// - Parameters:
    ///   - url: The URL of the website where the favicon will be searched for.
    ///   - configuration: The configuration settings for the search. Defaults to `.defaultConfiguration`.
    ///
    public init(
        url: URL,
        configuration: FaviconFinder.Configuration = .defaultConfiguration
    ) {
        self.url = url
        self.configuration = configuration
    }

}

// MARK: - Public

public extension FaviconFinder {

    /// Initiates the search for favicon URLs using available sources.
    ///
    /// - Important: If the user has set a source preference in the configuration, that source will be prioritized first.
    ///
    /// - Returns: An array of `FaviconURL` instances representing the locations of the favicons found.
    ///
    /// - Throws: Throws a `FaviconError.failedToFindFavicon` if no favicons could be found.
    /// - Throws: A `CancellationError` if the task is cancelled by the user.
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
                print("Using source: [\(source)]")
                do {
                    let finder = source.finder(url: url, configuration: config)
                    let faviconURLs = try await finder.find()
                    return faviconURLs
                } catch is CancellationError {
                    // The user has cancelled this, let's bubble this up
                    throw CancellationError()
                } catch let error as NSError {
                    // Check if the error is a URL cancellation error
                    // Map this to Swift's `CancellationError`s
                    if error.isCancelled {
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

    /// Cancels the current favicon fetching task if one is active.
    func cancel() {
        self.currentTask?.cancel()
    }

}

// MARK: - NSError

private extension NSError {

    /// Checks if the error represents a cancellation.
    var isCancelled: Bool {
        self.code == NSURLErrorCancelled
    }

}
