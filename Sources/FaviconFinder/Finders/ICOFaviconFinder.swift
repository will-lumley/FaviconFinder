//
//  ICOFaviconFinder.swift
//  Pods
//
//  Created by William Lumley on 26/5/21.
//

import Foundation

/// `ICOFaviconFinder` is a class that finds `.ico` favicons in a given website.
/// It conforms to the `FaviconFinderProtocol` and focuses on detecting and retrieving
/// favicons that are either located in the root of the domain or in subdomains.
///
/// This class first tries to find the favicon at the URL provided. If it cannot find it,
/// it will attempt to resolve the favicon by removing subdomains from the URL and
/// searching at the root domain (e.g., searching `google.com` if it failed on `subdomain.google.com`).
///
/// Use the `find()` method to start searching for `.ico` favicons.
///
/// - Note: This class handles meta-refresh redirects if enabled in the configuration.
///
final class ICOFaviconFinder: FaviconFinderProtocol {

    // MARK: - Properties

    /// The URL of the website to query for the `.ico` favicon.
    var url: URL

    /// Configuration options that allow users to customize the favicon search,
    /// such as specifying a preferred filename for `.ico` files.
    var configuration: FaviconFinder.Configuration

    /// The preferred filename for the `.ico` favicon.
    /// If no preference is provided in the configuration, defaults to `"favicon.ico"`.
    var preferredType: String {
        self.configuration.preferences[.ico] ?? "favicon.ico"
    }

    // MARK: - FaviconFinder

    /// Initializes an `ICOFaviconFinder` instance.
    ///
    /// - Parameters:
    ///   - url: The URL of the website to search for favicons.
    ///   - configuration: A configuration object that contains user preferences and options.
    ///
    /// - Returns: A new `ICOFaviconFinder` instance.
    ///
    required init(url: URL, configuration: FaviconFinder.Configuration) {
        self.url = url
        self.configuration = configuration
    }

    /// Finds the `.ico` favicon at the provided URL.
    ///
    /// This method attempts to retrieve the favicon in two steps:
    /// 1. It first tries to fetch the favicon at the provided URL.
    /// 2. If it fails, it removes subdomains from the URL and tries to find the favicon at the root domain.
    ///
    /// - Throws: `FaviconError.failedToFindFavicon` if no favicon can be found.
    ///
    /// - Returns: An array containing a single `FaviconURL` if the favicon is found, or throws an error
    /// otherwise.
    func find() async throws -> [FaviconURL] {

        // Get our URL without any appendages and add our favicon filename to it
        let baseUrl = URL(string: "/", relativeTo: self.url)
        guard let faviconUrl = URL(string: self.preferredType, relativeTo: baseUrl) else {
            throw FaviconError.failedToFindFavicon
        }

        // We have the URL, let's see if there's any valid image data here
        let fullFaviconUrlData = try await FaviconURLSession.dataTask(
            with: faviconUrl,
            checkForMetaRefreshRedirect: self.configuration.checkForMetaRefreshRedirect
        ).data

        // We found valid image data, woohoo!
        if (try? FaviconImage(data: fullFaviconUrlData)) != nil {
            return [
                FaviconURL(
                    source: faviconUrl,
                    format: .ico,
                    sourceType: .ico
                )
            ]
        }

        // We couldn't find any image, so let's try the root domain (just in case it's hiding there)
        // ie. If we couldn't find the image at "subdomain.google.com/favicon.ico", let's try "google.com/favicon.ico"

        // Create the URL, removing subdomains
        guard let base = self.url.urlWithoutSubdomains?.deletingPathExtension(),
                let rootURL = URL(string: self.preferredType, relativeTo: base) else {
            // We couldn't find the image at the root domain, so let's call this a failure
            throw FaviconError.failedToFindFavicon
        }

        // We created a URL without the subdomains, let's check if there's a valid image there
        let baseFaviconUrlData = try await FaviconURLSession.dataTask(
            with: rootURL,
            checkForMetaRefreshRedirect: self.configuration.checkForMetaRefreshRedirect
        ).data

        if (try? FaviconImage(data: baseFaviconUrlData)) != nil {
            // We found valid image data, woohoo!
            return [
                FaviconURL(
                    source: rootURL,
                    format: .ico,
                    sourceType: .ico
                )
            ]
        } else {
            // Well we couldn't find any valid image data at the provided URL, nor the root domain, game over.
            throw FaviconError.failedToFindFavicon
        }
    }

}
