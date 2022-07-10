//
//  FaviconFinder.swift
//  FaviconFinder
//
//  Created by William Lumley on 16/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

#if targetEnvironment(macCatalyst)
import UIKit
public typealias FaviconImage = UIImage

#elseif canImport(AppKit)
import AppKit
public typealias FaviconImage = NSImage

#elseif canImport(UIKit)
import UIKit
public typealias FaviconImage = UIImage
#endif

public class FaviconFinder: NSObject {

    // MARK: - Properties

    /// The base URL of the site we're trying to extract from
    private var url: URL

    /// Which download type our user would prefer to use
    private var preferredType: FaviconDownloadType

    /// Which preferences the user has for each download type
    private var preferences: [FaviconDownloadType: String]

    /// Indicates if we should check for a meta-refresh-redirect tag in the HTML header
    private var checkForMetaRefreshRedirect: Bool

    /// Indicates if FaviconFinder should download the image for the user upon detection
    private var downloadImage: Bool

    /// Prints useful states and errors when enabled
    private var logEnabled: Bool

    // MARK: - FaviconFinder

    public init(
        url: URL,
        preferredType: FaviconDownloadType = .html,
        preferences: [FaviconDownloadType: String] = [:],
        checkForMetaRefreshRedirect: Bool = false,
        downloadImage: Bool = true,
        logEnabled: Bool = false
    ) {
        self.url = url
        self.preferredType = preferredType
        self.preferences = preferences
        self.checkForMetaRefreshRedirect = checkForMetaRefreshRedirect
        self.downloadImage = downloadImage
        self.logEnabled = logEnabled
    }

    /**
     Begins the quest to find our Favicon
     - parameter onCompletion: The closure that will be called when the image is found (or not found)
    */
    public func downloadFavicon() async throws -> Favicon {

        // All of the download types available to us, and ones we'll fallback onto if this one fails.
        // As each download type fails, we'll remove it from the list and try an alternative.
        var allDownloadTypes = FaviconDownloadType.allTypes

        // Get the users preferred download type, and remove the users preferred download type from our list of potential download types
        var currentDownloadType = self.preferredType
        allDownloadTypes.removeAll { $0 == currentDownloadType }

        func search(downloadType: FaviconDownloadType) async throws -> Favicon {
            // Setup the download, and get it to search for the URL
            let downloader = downloadType.downloader(
                url: self.url,
                preferredType: self.preferences[downloadType],
                checkForMetaRefreshRedirect: self.checkForMetaRefreshRedirect,
                logEnabled: self.logEnabled
            )

            // Let's try and get the URL of the Favicon
            let url = try await downloader.search()

            // If we're not supposed to download the image, just return the URL
            if self.downloadImage == false {
                return url.emptyImage
            }

            // We found the URL 🎉 Now let's download the image
            return try await downloadImage(at: url.url, type: url.type)
        }

        do {
            return try await search(downloadType: currentDownloadType)
        } catch {
            guard let newDownloadType = allDownloadTypes.first else {
                // We have ran out of potential downloader types, and we never found the favicon. Game over.
                throw FaviconError.failedToFindFavicon
            }

            // We couldn't find our favicon with that download type, so let's try the next type
            // Get the users preferred download type, and remove the users preferred download type from our list of potential download types
            currentDownloadType = newDownloadType
            allDownloadTypes.removeAll { $0 == currentDownloadType }

            // Try again, with a new download type
            return try await search(downloadType: currentDownloadType)
        }
    }
}

private extension FaviconFinder {

    /**
     Downloads an image from the provided URL
     - parameter url: The URL at which we assume an image is at
     */
    func downloadImage(at url: URL, type: FaviconType) async throws -> Favicon {
        let data = try await URLSession.shared.data(from: url).0
        guard let image = FaviconImage(data: data) else {
            if self.logEnabled {
                print("Could NOT create favicon from data.")
            }
            throw FaviconError.invalidImage
        }
        
        let downloadType = FaviconDownloadType(type: type)
        return Favicon(image: image, data: data, url: url, type: type, downloadType: downloadType)
    }

}
