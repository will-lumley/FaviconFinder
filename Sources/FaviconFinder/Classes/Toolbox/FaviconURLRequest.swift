//
//  FaviconURLRequest.swift
//  Pods
//
//  Created by William Lumley on 5/3/2022.
//

import Foundation

#if os(Linux)
import FoundationNetworking
#endif

#if canImport(SwiftSoup)
import SwiftSoup
#endif

class FaviconURLRequest {

    // MARK: - Types

    typealias OnComplete = (Data?, URLResponse?, Error?) -> Void

    // MARK: - URLRequest

    #if os(Linux)
    static func dataTask(with url: URL, checkForMetaRefreshRedirect: Bool = false, onComplete: @escaping OnComplete) {
        print("Making request to URL: \(url)")
        let group = DispatchGroup.init()
        group.enter()

        let dataTask = URLSession.shared.dataTask(with: url) { data, urlResponse, error in
            defer {
                group.leave()
            }

            // If we're supposed to check for the meta-refresh-redirect,
            // parse the HTML and check for a meta-refresh-redirect
            if checkForMetaRefreshRedirect {
                do {
                    // Make sure our data exists
                    guard let data = data else {
                        onComplete(data, urlResponse, error)
                        return
                    }

                    // Make sure we can parse the response into a string
                    guard let htmlStr = String(data: data, encoding: .utf8) else {
                        onComplete(data, urlResponse, error)
                        return
                    }

                    // Parse the string into a workable HTML object
                    let html = try SwiftSoup.parse(htmlStr)

                    // Get the head of the HTML
                    guard let head = html.head() else {
                        onComplete(data, urlResponse, error)
                        return
                    }

                    // Get all meta-refresh-redirect tag
                    let httpEquivs = try head.getElementsByAttribute("http-equiv")
                    guard let httpEquiv = try httpEquivs.whereAttr("http-equiv", equals: "refresh") else {
                        onComplete(data, urlResponse, error)
                        return
                    }

                    // Get the URL
                    var redirectURLStr = try httpEquiv.attr("content")

                    // Remove the 0;URL=
                    redirectURLStr = redirectURLStr.replacingOccurrences(of: "0;URL=", with: "")

                    // Determine if this is a whole new URL, or something we should append to the current one
                    let brandNewURL = Regex.testForHttpsOrHttp(input: redirectURLStr)

                    // If this is a brand new URL
                    if brandNewURL {
                        guard let redirectURL = URL(string: redirectURLStr) else {
                            return
                        }

                        URLSession.shared.dataTask(with: redirectURL) { data, urlResponse, error in
                            onComplete(data, urlResponse, error)
                        }.resume()
                    }

                    // If this something we should append to our current URL
                    else {
                        let needsPrependingSlash = url.absoluteString.last != "/" && redirectURLStr.first != "/"
                        if needsPrependingSlash {
                            redirectURLStr = "\(url.absoluteString)/\(redirectURLStr)"
                        }
                        else {
                            redirectURLStr = "\(url.absoluteString)\(redirectURLStr)"
                        }

                        guard let redirectURL = URL(string: redirectURLStr) else {
                            return
                        }

                        URLSession.shared.dataTask(with: redirectURL) { data, urlResponse, error in
                            onComplete(data, urlResponse, error)
                        }.resume()
                    }
                }
                catch {
                    onComplete(data, urlResponse, error)
                    return
                }

            }
            // We're not supposed to check for the meta-refresh-redirect, so just return the data
            else {
                print("Data: \(data)")
                print("Error: \(error)")
                onComplete(data, urlResponse, error)
            }
        }
        dataTask.resume()

        group.wait()
    }
    #else
    static func dataTask(with url: URL, checkForMetaRefreshRedirect: Bool = false) async throws -> (Data, URLResponse) {
        let urlResponse = try await URLSession.shared.data(from: url)

        let data = urlResponse.0
        let response = urlResponse.1

        if checkForMetaRefreshRedirect {
            // Make sure we can parse the response into a string
            guard let htmlStr = String(data: data, encoding: response.encoding) else {
                return (data, response)
            }

            // Parse the string into a workable HTML object
            let html = try SwiftSoup.parse(htmlStr)

            // Get the head of the HTML
            guard let head = html.head() else {
                return (data, response)
            }

            // Get all meta-refresh-redirect tag
            let httpEquivs = try head.getElementsByAttribute("http-equiv")
            guard let httpEquiv = try httpEquivs.whereAttr("http-equiv", equals: "refresh") else {
                return (data, response)
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
                    return (data, response)
                }

                return try await URLSession.shared.data(from: redirectURL)
            }

            // If this something we should append to our current URL
            else {
                let needsPrependingSlash = url.absoluteString.last != "/" && redirectURLStr.first != "/"
                if needsPrependingSlash {
                    redirectURLStr = "\(url.absoluteString)/\(redirectURLStr)"
                }
                else {
                    redirectURLStr = "\(url.absoluteString)\(redirectURLStr)"
                }

                // If we can't form a valid redirect URL, we'll just return the data from the original page
                guard let redirectURL = URL(string: redirectURLStr) else {
                    return (data, response)
                }

                return try await URLSession.shared.data(from: redirectURL)
            }
        }
        // We're not supposed to check for the meta-refresh-redirect, so just return the data
        else {
            return (data, response)
        }
    }
    #endif
}

// MARK: - SwiftSoup.Elements

private extension Elements {

    func whereAttr(_ attribute: String, equals value: String) throws -> Element? {
        for element in self {
            if try element.attr(attribute) == value {
                return element
            }
        }

        return nil
    }

}
