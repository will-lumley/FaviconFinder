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
import NIOHTTP1
import NIOFoundationCompat
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
        checkForMetaRefreshRedirect: Bool = false
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
        checkForMetaRefreshRedirect: Bool = false
    ) async throws -> Response {
        let response = Response(try await URLSession.shared.data(from: url))

        let data = response.data

        if checkForMetaRefreshRedirect {
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

                // If we can't form a valid redirect URL, we'll just return the data from the original page
                guard let redirectURL = URL(string: redirectURLStr) else {
                    return response
                }

                let redirectResponse = Response(try await URLSession.shared.data(from: redirectURL))
                return redirectResponse
            }
        } else {
            // We're not supposed to check for the meta-refresh-redirect,
            // so just return the data.
            return response
        }
    }

    #else

    static func appleDataTask(
            with url: URL,
            checkForMetaRefreshRedirect: Bool = false
        ) async throws -> Response {
            let response = Response(try await URLSession.shared.data(from: url))

            let data = response.data

            if checkForMetaRefreshRedirect {
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

                    let redirectResponse = Response(try await URLSession.shared.data(from: redirectURL))
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
