//
//  ICOFaviconFinder.swift
//  Pods
//
//  Created by William Lumley on 26/5/21.
//

import Foundation

class RootICOFaviconFinder: FaviconFinderProtocol {

    var url: URL
    var preferredType: String
    var logEnabled: Bool

    required init(url: URL, preferredType: String, logEnabled: Bool) {
        self.url = url
        self.preferredType = preferredType
        self.logEnabled = logEnabled
    }

    func search(onFind: @escaping ((Result<FaviconURL, FaviconError>) -> Void)) {
        guard let url = self.url.urlWithoutSubdomains?.appendingPathComponent(self.preferredType) else {
            onFind(.failure(.failedToFindFavicon))
            return
        }

        let faviconURL = FaviconURL(url: url, type: .rootIco)
        onFind(.success(faviconURL))
    }

}
