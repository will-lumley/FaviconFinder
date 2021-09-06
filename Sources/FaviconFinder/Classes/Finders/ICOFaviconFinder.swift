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

    func search() async throws -> FaviconURL {
        // TODO: Check that there's an actual image at the path.
        // If there's not, try the root instead.
        // Then, remove the RootICO finder and type.

        let baseUrl = URL(string: "/", relativeTo: self.url)
        guard let faviconUrl = URL(string: self.preferredType, relativeTo: baseUrl) else {
            throw FaviconError.failedToFindFavicon
        }
        
        let data = try await URLSession.shared.data(from: faviconUrl).0
        if FaviconImage(data: data) != nil {
            return FaviconURL(url: faviconUrl, type: .ico)
        } else {
            guard let base = self.url.urlWithoutSubdomains?.deletingPathExtension(),
                  let rootURL = URL(string: self.preferredType, relativeTo: base) else {
                      // We couldn't find the image at the root domain, so let's give the user a failure.
                      throw FaviconError.failedToFindFavicon
                  }
            let data = try await URLSession.shared.data(from: rootURL).0
            
            if FaviconImage(data: data) != nil {
                return FaviconURL(url: rootURL, type: .ico)
            } else {
                throw FaviconError.failedToFindFavicon
            }
        }
    }

}
