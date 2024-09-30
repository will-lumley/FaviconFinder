//
//  MockFaviconFinder.swift
//  Pods
//
//  Created by William Lumley on 26/5/21.
//

import Foundation

/// `MockFaviconFinder` is a mock implementation of the `FaviconFinderProtocol`, used for testing purposes.
/// It simulates the behavior of a real favicon finder by either returning a predefined set of `FaviconURL`
/// instances or throwing a specified error after a configurable delay.
///
/// This class can be useful in unit tests where you need to simulate various favicon-finding scenarios
/// without making actual network requests.
///
/// - Note: The delay before returning the result is controlled by the `duration` property,
/// and errors can be simulated by setting the `error` property.
///
final class MockFaviconFinder: FaviconFinderProtocol {

    // MARK: - Properties

    /// The URL of the website (simulated in this case).
    var url: URL

    /// Configuration options for the mock favicon finder (simulated in this case).
    var configuration: FaviconFinder.Configuration

    /// The preferred favicon type, hardcoded to `"test.png"` for this mock.
    var preferredType: String {
        "test.png"
    }

    /// The amount of time, in seconds, that the mock will wait before returning the result in the `find()` method.
    ///
    /// - Note: This delay simulates network latency or processing time in tests.
    ///
    var duration = 5

    /// An optional error that will be thrown by the `find()` method if set.
    ///
    /// - Note: This allows you to simulate failure scenarios in unit tests.
    ///
    var error: FaviconError?

    // MARK: - FaviconFinder

    /// Initializes a `MockFaviconFinder` instance with a specified URL and configuration.
    ///
    /// - Parameters:
    ///   - url: The URL to simulate favicon retrieval for.
    ///   - configuration: A configuration object for simulating different behaviors.
    ///
    /// - Returns: A new `MockFaviconFinder` instance.
    ///
    required init(url: URL, configuration: FaviconFinder.Configuration) {
        self.url = url
        self.configuration = configuration
    }

    /// Simulates finding favicons by waiting for the specified duration and then either
    /// returning a predefined set of `FaviconURL` instances or throwing an error if one is set.
    ///
    /// - Throws: `FaviconError` if the `error` property is set.
    ///
    /// - Returns: An array of predefined `FaviconURL` instances if no error is set.
    /// 
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
                htmlSizeTag: "100x140"
            ),
            .init(
                source: URL(string: "https://apple.com")!,
                format: .appleTouchIcon,
                sourceType: .html,
                htmlSizeTag: "100x90"
            ),
            .init(
                source: URL(string: "https://facebook.com")!,
                format: .appleTouchIcon,
                sourceType: .html,
                htmlSizeTag: "100x90"
            )
        ]
    }

}
