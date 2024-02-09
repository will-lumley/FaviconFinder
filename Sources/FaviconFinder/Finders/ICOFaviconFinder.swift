//
//  ICOFaviconFinder.swift
//  Pods
//
//  Created by William Lumley on 26/5/21.
//

import Foundation

class ICOFaviconFinder: FaviconFinderProtocol {

    // MARK: - Properties

    var url: URL
    var configuration: FaviconFinder.Configuration
    
    var preferredType: String {
        self.configuration.preferences[.ico] ?? "favicon.ico"
    }

    // MARK: - FaviconFinder

    required init(url: URL, configuration: FaviconFinder.Configuration) {
        self.url = url
        self.configuration = configuration
    }

    func find() async throws -> [FaviconURL] {

        // Get our URL without any appendages and add our favicon filename to it
        let baseUrl = URL(string: "/", relativeTo: self.url)
        guard let faviconUrl = URL(string: self.preferredType, relativeTo: baseUrl) else {
            throw FaviconError.failedToFindFavicon
        }

        // We have the URL, let's see if there's any valid image data here
        let fullFaviconUrlData = try await FaviconURLRequest.dataTask(
            with: faviconUrl,
            checkForMetaRefreshRedirect: self.configuration.checkForMetaRefreshRedirect
        ).data

        // We found valid image data, woohoo!
        if (try? FaviconImage(data: fullFaviconUrlData)) != nil {
            return [FaviconURL(source: faviconUrl, format: .ico, sourceType: .ico, sizeTag: nil)]
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
        let baseFaviconUrlData = try await FaviconURLRequest.dataTask(
            with: faviconUrl,
            checkForMetaRefreshRedirect: self.configuration.checkForMetaRefreshRedirect
        ).data

        if (try? FaviconImage(data: baseFaviconUrlData)) != nil {
            // We found valid image data, woohoo!
            return [FaviconURL(source: rootURL, format: .ico, sourceType: .ico, sizeTag: nil)]
        } else {
            // Well we couldn't find any valid image data at the provided URL, nor the root domain, game over.
            throw FaviconError.failedToFindFavicon
        }
    }

}
