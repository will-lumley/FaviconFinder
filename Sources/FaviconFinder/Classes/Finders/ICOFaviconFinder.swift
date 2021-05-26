//
//  ICOFaviconFinder.swift
//  Pods
//
//  Created by William Lumley on 26/5/21.
//

import Foundation

class ICOFaviconFinder: FaviconFinderProtocol {

    var url: URL
    var logEnabled: Bool

    private let filename = "favicon.ico"

    required init(url: URL, logEnabled: Bool) {
        self.url = url
        self.logEnabled = logEnabled
    }

    func search(onFind: @escaping ((Result<URL, FaviconError>) -> Void)) {
        let url = self.url.appendingPathComponent(self.filename)
        onFind(.success(url))
    }

}
