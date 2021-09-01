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
    
    /// Prints useful states and errors when enabled
    private var logEnabled: Bool

    /// Which download type our user would prefer to use
    private var preferredType: FaviconDownloadType

    /// Which preferences the user has for each download type
    private var preferences: [FaviconDownloadType: String]

    // MARK: - FaviconFinder

    public init(url: URL, preferredType: FaviconDownloadType = .html, preferences: [FaviconDownloadType: String] = [:], logEnabled: Bool = false) {
        self.url = url
        self.preferredType = preferredType
        self.preferences = preferences
        self.logEnabled = logEnabled
    }

    /**
     Begins the quest to find our Favicon
     - parameter onCompletion: The closure that will be called when the image is found (or not found)
    */
    public func downloadFavicon(_ onCompletion: @escaping (_ result: Result<Favicon, FaviconError>) -> Void) {

        // All of the download types available to us, and ones we'll fallback onto if this one fails.
        // As each download type fails, we'll remove it from the list and try an alternative.
        var allDownloadTypes = FaviconDownloadType.allTypes

        // Get the users preferred download type, and remove the users preferred download type from our list of potential download types
        var currentDownloadType = self.preferredType
        allDownloadTypes.removeAll { $0 == currentDownloadType }

        search(downloadType: currentDownloadType)

        func search(downloadType: FaviconDownloadType) {
            // Setup the download, and get it to search for the URL
            let downloader = downloadType.downloader(url: self.url, preferredType: self.preferences[downloadType], logEnabled: self.logEnabled)
            downloader.search(onFind: { [unowned self] result in
                switch result {
                case .success(let faviconURL):

                    // Yay! We successfully found a URL. Let's download the image
                    self.downloadImage(at: faviconURL.url, type: faviconURL.type, onDownload: { result in
                        switch result {
                        case .success(let favicon):
                            // We successfully downloaded the image. We won!
                            onCompletion(.success(favicon))
                        
                        case .failure:
                            // We successfully found the URL, but failed to download the image. Let's try again.
                            trySearchAgain()
                        }
                    })

                case .failure:
                    // We couldn't find the URL. Let's try again.
                    trySearchAgain()
                }
            })
        }

        func trySearchAgain() {
            guard let newDownloadType = allDownloadTypes.first else {
                // We have ran out of potential downloader types, and we never found the favicon. Game over.
                onCompletion(.failure(.failedToFindFavicon))
                return
            }

            // We couldn't find our favicon with that download type, so let's try the next type
            // Get the users preferred download type, and remove the users preferred download type from our list of potential download types
            currentDownloadType = newDownloadType
            allDownloadTypes.removeAll { $0 == currentDownloadType }

            // Try again, with a new download type
            search(downloadType: currentDownloadType)
        }
    }

}

private extension FaviconFinder {

    /**
     Downloads an image from the provided URL
     - parameter url: The URL at which we assume an image is at
     */
    private func downloadImage(at url: URL, type: FaviconType, onDownload: @escaping ((_ result: Result<Favicon, FaviconError>) -> Void)) {
        //Now that we've got the URL of the image, let's download the image
        URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
            if let error = error {
                if self.logEnabled {
                    print("Could NOT download favicon from url: \(url), error: \(error)")
                }
                onDownload(.failure(.failedToDownloadFavicon))

                return
            }
            
            //Make sure our data exists
            guard let data = data else {
                if self.logEnabled {
                    print("Could NOT get favicon from url: \(self.url), Data was nil.")
                }
                onDownload(.failure(.emptyFavicon))

                return
            }
            
            guard let image = FaviconImage(data: data) else {
                if self.logEnabled {
                    print("Could NOT create favicon from data.")
                }
                onDownload(.failure(.invalidImage))
                
                return
            }
            
            if self.logEnabled {
                print("Successfully extracted favicon from url: \(self.url)")
            }

            let downloadType = FaviconDownloadType(type: type)

            let favicon = Favicon(image: image, url: url, type: type, downloadType: downloadType)
            onDownload(.success(favicon))
            
        }).resume()
    }

}
