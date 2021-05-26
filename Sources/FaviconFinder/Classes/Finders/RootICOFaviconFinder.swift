//
//  ICOFaviconFinder.swift
//  Pods
//
//  Created by William Lumley on 26/5/21.
//

import Foundation

class RootICOFaviconFinder: FaviconFinderProtocol {

    var url: URL
    var logEnabled: Bool

    private let filename = "favicon.ico"

    required init(url: URL, logEnabled: Bool) {
        self.url = url
        self.logEnabled = logEnabled
    }

    func search(onFind: @escaping ((Result<URL, FaviconError>) -> Void)) {
        guard let url = self.url.urlWithoutSubdomains?.appendingPathComponent(self.filename) else {
            onFind(.failure(.failedToFindFavicon))
            return
        }

        onFind(.success(url))
    }

}
