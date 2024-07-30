//
//  MockFaviconFinder.swift
//  Pods
//
//  Created by William Lumley on 26/5/21.
//

import Foundation

class MockFaviconFinder: FaviconFinderProtocol {

    // MARK: - Properties

    var url: URL
    var configuration: FaviconFinder.Configuration

    var preferredType: String {
        "test.png"
    }

    /// The amount of time, in seconds, that we'll wait before returning our `find()` result
    var duration = 5

    /// The error that we'll return in our `find()`
    var error: FaviconError?

    // MARK: - FaviconFinder

    required init(url: URL, configuration: FaviconFinder.Configuration) {
        self.url = url
        self.configuration = configuration
    }

    func find() async throws -> [FaviconURL] {
        try await Task.sleep(nanoseconds: UInt64(self.duration) * 1_000_000_000)

        // Throw the error if we're supposed to
        if let error {
            throw error
        }

        // Otherwise return a URL
        return [
            .init(
                source: URL(string: "https://google.com")!,
                format: .appleTouchIcon,
                sourceType: .html,
                sizeTag: nil
            )
        ]
    }

}
