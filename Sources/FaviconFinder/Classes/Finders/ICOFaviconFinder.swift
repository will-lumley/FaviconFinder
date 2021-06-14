//
//  ICOFaviconFinder.swift
//  Pods
//
//  Created by William Lumley on 26/5/21.
//

import Foundation

class ICOFaviconFinder: FaviconFinderProtocol {

    var url: URL
    var preferredType: String
    var logEnabled: Bool

    required init(url: URL, preferredType: String?, logEnabled: Bool) {
        self.url = url
        self.preferredType = preferredType ?? "favicon.ico" //Default to the filename of "favicon.ico" if user does not present us with one
        self.logEnabled = logEnabled
    }

    func search(onFind: @escaping ((Result<FaviconURL, FaviconError>) -> Void)) {
        // TODO: Check that there's an actual image at the path.
        // If there's not, try the root instead.
        // Then, remove the RootICO finder and type.

        let baseUrl = URL(string: "/", relativeTo: self.url)
        guard let faviconUrl = URL(string: self.preferredType, relativeTo: baseUrl) else {
            onFind(.failure(.failedToFindFavicon))
            return
        }
        
        // Switch to the background thread, as we'll be doing some networking
        DispatchQueue.global().async {

            // We have the URL, let's see if there's any valid image data here
            if let data = try? Data(contentsOf: faviconUrl), let _ = FaviconImage(data: data) {
                // We found valid image data, woohoo!
                let faviconURL = FaviconURL(url: faviconUrl, type: .ico)
                onFind(.success(faviconURL))
            } else {
                // We couldn't find any image, but let's try the root domain (just in case it's hiding there)
                // ie. If we couldn't find the image at "subdomain.google.com/favicon.ico", let's try "google.com/favicon.ico"

                // Create the URL, removing subdomains
                guard let base = self.url.urlWithoutSubdomains?.deletingPathExtension(),
                      let rootURL = URL(string: self.preferredType, relativeTo: base) else {
                    // We couldn't find the image at the root domain, so let's give the user a failure.
                    onFind(.failure(.failedToFindFavicon))
                    return
                }

                // We created a URL without the subdomains, let's check if there's a valid image there
                if let data = try? Data(contentsOf: rootURL), let _ = FaviconImage(data: data) {
                    // We found valid image data, woohoo!
                    let faviconURL = FaviconURL(url: rootURL, type: .ico)
                    onFind(.success(faviconURL))
                } else {
                    // Well we couldn't find any valid image data at the provided URL, nor the root domain, game over.
                    onFind(.failure(.failedToFindFavicon))
                }
            }
        }
    }

}
