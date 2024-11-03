//
//  FaviconURLSession.swift
//  FaviconFinder
//
//  Created by William Lumley on 5/3/2022.
//

#if os(Linux)
import AsyncHTTPClient
import FoundationNetworking
import NIOCore
import NIOFoundationCompat
import NIOHTTP1
#endif

import Foundation
import SwiftSoup

/// The `FaviconURLSession` class wraps `URLSession` to provide consistent behavior for downloading favicons,
/// with support for handling meta-refresh redirects and bridging async functionality
/// for both Apple and Linux platforms.
///
/// - Why a wrapper around `URLSession`?
///   1. **Meta-refresh redirects**: `URLSession` does not handle meta-refresh redirects. This wrapper ensures
///      such redirects are handled appropriately, allowing the caller to ignore such details.
///   2. **Cross-platform support**: On Linux, `FoundationNetworking` doesn't support async/await functionality.
///      This wrapper handles the differences between Apple and Linux platforms, abstracting away the complexity
///      for the caller.
///
/// The `dataTask` function supports HTTP headers and optional checking for meta-refresh redirects.
///
/// - Parameters:
///   - url: The URL to send the request to.
///   - checkForMetaRefreshRedirect: A Boolean indicating whether to check for meta-refresh redirects in the HTML.
///     Defaults to `false`.
///   - httpHeaders: Optional HTTP headers to include in the request.
///
final class FaviconURLSession {

    /// Downloads data from the provided URL, optionally checking for meta-refresh redirects
    /// and handling cross-platform differences between Apple and Linux.
    ///
    /// - Parameters:
    ///   - url: The URL from which to download the data.
    ///   - checkForMetaRefreshRedirect: A Boolean indicating whether to check for
    ///   meta-refresh redirects in the response.
    ///     Defaults to `false`.
    ///   - httpHeaders: Optional dictionary of HTTP headers to include in the request.
    ///     The keys represent header field names, and the values are their respective values.
    ///   - recursionDepth: How many calls deep we currently are into redirecting
    ///   - maxDepth: The maximum amount of calls deep we'll go before calling it a day and returning an error
    ///
    /// - Returns: A `Response` object containing the data and headers of the response.
    ///
    /// - Throws: Throws if the network request fails or if meta-refresh redirect processing fails.
    ///
    static func dataTask(
        with url: URL,
        checkForMetaRefreshRedirect: Bool = false,
        httpHeaders: [String?: String]? = nil,
        recursionDepth: Int = 0,
        maxDepth: Int = 5
    ) async throws -> Response {
#if os(Linux)
        try await linuxDataTask(
            with: url,
            checkForMetaRefreshRedirect: checkForMetaRefreshRedirect
        )
#else
        try await appleDataTask(
            with: url,
            checkForMetaRefreshRedirect: checkForMetaRefreshRedirect
        )
#endif
    }

}

// MARK: - Private

private extension FaviconURLSession {

#if os(Linux)

    /// Downloads data from the provided URL, optionally checking for meta-refresh redirects
    /// and handling cross-platform differences between Apple and Linux.
    ///
    /// - Parameters:
    ///   - url: The URL from which to download the data.
    ///   - checkForMetaRefreshRedirect: A Boolean indicating whether to check for
    ///   meta-refresh redirects in the response.
    ///     Defaults to `false`.
    ///   - httpHeaders: Optional dictionary of HTTP headers to include in the request.
    ///     The keys represent header field names, and the values are their respective values.
    ///   - recursionDepth: How many calls deep we currently are into redirecting
    ///   - maxDepth: The maximum amount of calls deep we'll go before calling it a day and returning an error
    ///
    /// - Returns: A `Response` object containing the data and headers of the response.
    ///
    /// - Throws: Throws if the network request fails or if meta-refresh redirect processing fails.
    ///
    static func linuxDataTask(
        with url: URL,
        checkForMetaRefreshRedirect: Bool = false,
        httpHeaders: [String: String?]? = nil,
        recursionDepth: Int = 0,
        maxDepth: Int = 5
    ) async throws -> Response {
        guard recursionDepth < maxDepth else {
            throw URLError(.redirectToNonExistentLocation)
        }

        let httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
        defer {
            try? httpClient.shutdown()
        }

        // Convert headers to HTTPHeaders
        var headers = HTTPHeaders()
        if let httpHeaders = httpHeaders {
            for (key, value) in httpHeaders {
                headers.add(name: key, value: value ?? "")
            }
        }

        // Create the request
        var request = HTTPClientRequest(url: url.absoluteString)
        request.method = .GET
        request.headers = headers

        // Send the request
        let response = try await httpClient.execute(request, timeout: .seconds(15))

        // Collect the response body
        let byteBuffer = try await response.body.collect(upTo: 2048 * 1024) // 2MB
        let data = Data(buffer: byteBuffer)

        // Check for meta-refresh redirect if needed
        if checkForMetaRefreshRedirect {
            guard let htmlStr = String(data: data, encoding: .utf8) else {
                throw URLError(.badServerResponse)
            }
            let html = try SwiftSoup.parse(htmlStr)

            if let head = html.head() {
                let httpEquiv = try head
                    .getElementsByAttribute("http-equiv")
                    .whereAttr("http-equiv", equals: "refresh")

                if let httpEquiv {
                    var redirectURLStr = try httpEquiv
                        .attr("content")
                        .replacingOccurrences(of: "0;URL=", with: "")
                    let brandNewURL = Regex.testForHttpsOrHttp(input: redirectURLStr)

                    if brandNewURL, let redirectURL = URL(string: redirectURLStr) {
                        return try await linuxDataTask(
                            with: redirectURL,
                            checkForMetaRefreshRedirect: false,
                            httpHeaders: httpHeaders
                        )
                    } else {
                        let needsPrependingSlash = url.absoluteString.last != "/" && redirectURLStr.first != "/"
                        if needsPrependingSlash {
                            redirectURLStr = "\(url.absoluteString)/\(redirectURLStr)"
                        } else {
                            redirectURLStr = "\(url.absoluteString)\(redirectURLStr)"
                        }
                        if let redirectURL = URL(string: redirectURLStr) {
                            return try await linuxDataTask(
                                with: redirectURL,
                                checkForMetaRefreshRedirect: false,
                                httpHeaders: httpHeaders,
                                recursionDepth: recursionDepth + 1
                            )
                        }
                    }
                }
            }
        }

        // Return the response with data and headers
        return Response((data, response.headers))
    }

    #else

    /// Downloads data from the provided URL, optionally checking for meta-refresh redirects
    /// and handling cross-platform differences between Apple and Linux.
    ///
    /// - Parameters:
    ///   - url: The URL from which to download the data.
    ///   - checkForMetaRefreshRedirect: A Boolean indicating whether to check for
    ///   meta-refresh redirects in the response.
    ///     Defaults to `false`.
    ///   - httpHeaders: Optional dictionary of HTTP headers to include in the request.
    ///     The keys represent header field names, and the values are their respective values.
    ///   - recursionDepth: How many calls deep we currently are into redirecting
    ///   - maxDepth: The maximum amount of calls deep we'll go before calling it a day and returning an error
    ///
    /// - Returns: A `Response` object containing the data and headers of the response.
    ///
    /// - Throws: Throws if the network request fails or if meta-refresh redirect processing fails.
    static func appleDataTask( // swiftlint:disable:this cyclomatic_complexity
            with url: URL,
            checkForMetaRefreshRedirect: Bool = false,
            httpHeaders: [String: String?]? = nil,
            recursionDepth: Int = 0,
            maxDepth: Int = 5
        ) async throws -> Response {
            guard recursionDepth < maxDepth else {
                throw URLError(.redirectToNonExistentLocation)
            }

            // Create our request
            var request = URLRequest(url: url)

            // If there's HTTP headers, add them
            if let httpHeaders {
                for (key, value) in httpHeaders {
                    request.setValue(value, forHTTPHeaderField: key)
                }
            }

            // Fetch our response
            let response = Response(
                try await URLSession.shared.data(for: request)
            )

            // If the user wants to check for meta-refresh-redirect, do so and
            // if we find a redirect, follow that up
            if checkForMetaRefreshRedirect {
                let data = response.data

                // Make sure we can parse the response into a string
                guard let htmlStr = String(data: data, encoding: response.textEncoding) else {
                    return response
                }

                // Parse the string into a workable HTML object
                let html = try SwiftSoup.parse(htmlStr)

                // Get the head of the HTML
                guard let head = html.head() else {
                    return response
                }

                // Get all meta-refresh-redirect tag
                let httpEquivs = try head.getElementsByAttribute("http-equiv")
                guard let httpEquiv = try httpEquivs.whereAttr("http-equiv", equals: "refresh") else {
                    return response
                }

                // Get the URL
                var redirectURLStr = try httpEquiv.attr("content")

                // Remove the 0;URL=
                redirectURLStr = redirectURLStr.replacingOccurrences(of: "0;URL=", with: "")

                // Determine if this is a whole new URL, or something we should append to the current one
                let brandNewURL = Regex.testForHttpsOrHttp(input: redirectURLStr)

                // If this is a brand new URL
                if brandNewURL {
                    // If we can't form a valid redirect URL, we'll just return the data from the original page
                    guard let redirectURL = URL(string: redirectURLStr) else {
                        return response
                    }

                    let redirectResponse = Response(try await URLSession.shared.data(from: redirectURL))
                    return redirectResponse
                }

                // If this something we should append to our current URL
                else {
                    let needsPrependingSlash = url.absoluteString.last != "/" && redirectURLStr.first != "/"
                    if needsPrependingSlash {
                        redirectURLStr = "\(url.absoluteString)/\(redirectURLStr)"
                    } else {
                        redirectURLStr = "\(url.absoluteString)\(redirectURLStr)"
                    }

                    // If we can't form a valid redirect URL, 
                    // we'll just return the data from the original page.
                    guard let redirectURL = URL(string: redirectURLStr) else {
                        return response
                    }

                    var redirectRequest = URLRequest(url: redirectURL)
                    if let httpHeaders {
                        for (key, value) in httpHeaders {
                            redirectRequest.setValue(value, forHTTPHeaderField: key)
                        }
                    }

                    let redirectResponse = Response(
                        try await URLSession.shared.data(from: redirectURL)
                    )
                    return redirectResponse
                }
            }
            // We're not supposed to check for the meta-refresh-redirect, 
            // so just return the data.
            else {
                return response
            }
        }

    #endif

}

// MARK: - Linux Specific URLSession Override

#if os(Linux)

/// A custom extension of `URLSession` to support asynchronous network requests on Linux using NIO's `HTTPClient`.
private extension URLSession {

    /// Allows a convenient async/await implementation of a network call on Linux.
    ///
    /// - Note: This function is only available on Linux systems, as `URLSession` on Linux lacks `async/await` support.
    /// - Parameters:
    ///   - url: The URL to download data from.
    /// - Returns: A tuple containing the downloaded data and the HTTP headers from the response.
    /// - Throws: Throws an error if the network request fails or if the response data cannot be collected.
    ///
    func data(from url: URL) async throws -> (Data, HTTPHeaders) {
        let httpClient = HTTPClient(eventLoopGroupProvider: .singleton)

        let request = HTTPClientRequest(url: url.absoluteString)

        let response = try await httpClient.execute(request, timeout: .seconds(30))
        let byteBuffer = try await response.body.collect(upTo: Int.max)
        let data = Data(buffer: byteBuffer)

        try await httpClient.shutdown()

        return (data, response.headers)
    }

}
#endif

// MARK: - SwiftSoup.Elements

/// Filters an array of `Elements` (from SwiftSoup) to find the first element with the specified attribute and value.
private extension Elements {

    /// Finds an attribute that matches the condition in an array of Elements
    ///
    /// - Parameters:
    ///   - attribute: The attribute to search for (e.g., "http-equiv").
    ///   - value: The value the attribute must equal (e.g., "refresh").
    /// - Returns: The first `Element` that matches the attribute and value, or `nil` if no such element is found.
    /// - Throws: Throws an error if an element's attribute cannot be accessed.
    ///
    func whereAttr(_ attribute: String, equals value: String) throws -> Element? {
        for element in self where try element.attr(attribute) == value {
            return element
        }

        return nil
    }

}
