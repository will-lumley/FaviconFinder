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

/// Why is having our own wrapper around `URLSession` necessary? Great question. Usually I'd be very against
/// something like this, but I believe that in this use-case it's necessary for a number of reasons.
///
/// 1. Having all our Favicon download's come through this object allows for us to check for a 
/// meta-refresh redirect. `URLSession` doesn't check for meta-refresh redirect's so having
/// it here allows for the caller to not worry about such logic.
///
/// 2. The `URLSession` that comes with Linux (ie. `FoundationNetworking`) doesn't support `async await`
/// functionality, instead relying on archaic closures. Having this handled in `FaviconURLRequest` is neat so the
/// caller doesn't have to worry about handling the two different types of `URLSession` calls.
///
class FaviconURLSession {

    static func dataTask(
        with url: URL,
        checkForMetaRefreshRedirect: Bool = false,
        httpHeaders: [String?: String]? = nil
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

    static func linuxDataTask(
        with url: URL,
        checkForMetaRefreshRedirect: Bool = false,
        httpHeaders: [String: String?]? = nil
    ) async throws -> Response {
        let httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
        defer {
            try? httpClient.syncShutdown()
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
        let response = try await httpClient.execute(request, timeout: .seconds(30))

        // Collect the response body
        let byteBuffer = try await response.body.collect(upTo: Int.max)
        let data = Data(buffer: byteBuffer)

        // Check for meta-refresh redirect if needed
        if checkForMetaRefreshRedirect {
            let htmlStr = String(data: data, encoding: .utf8) ?? ""
            let html = try SwiftSoup.parse(htmlStr)
            let httpEquiv = try head.getElementsByAttribute("http-equiv").whereAttr("http-equiv", equals: "refresh")

            if let head = html.head(), let httpEquiv {
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
                            httpHeaders: httpHeaders
                        )
                    }
                }
            }
        }

        // Return the response with data and headers
        return Response((data, response.headers))
    }

    #else

    // swiftlint:disable:next cyclomatic_complexity
    static func appleDataTask(
            with url: URL,
            checkForMetaRefreshRedirect: Bool = false,
            httpHeaders: [String: String?]? = nil
        ) async throws -> Response {
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
private extension URLSession {

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

private extension Elements {

    func whereAttr(_ attribute: String, equals value: String) throws -> Element? {
        for element in self where try element.attr(attribute) == value {
            return element
        }

//        for element in self {
//            if try element.attr(attribute) == value {
//                return element
//            }
//        }

        return nil
    }

}
