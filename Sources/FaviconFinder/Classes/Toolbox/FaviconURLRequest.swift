//
//  FaviconURLRequest.swift
//  Pods
//
//  Created by William Lumley on 5/3/2022.
//

import Foundation

#if canImport(SwiftSoup)
import SwiftSoup
#endif

class FaviconURLRequest {

    static func dataTask(
        with url: URL,
        checkForMetaRefreshRedirect: Bool = false,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()
    ) {
        URLSession.shared.dataTask(with: url) { data, urlResponse, error in
            // If we're supposed to check for the meta-refresh-redirect,
            // parse the HTML and check for a meta-refresh-redirect
            if checkForMetaRefreshRedirect {

                do {
                    // Make sure our data exists
                    guard let data = data else {
                        completionHandler(data, urlResponse, error)
                        return
                    }

                    // Make sure we can parse the response into a string
                    guard let htmlStr = String(data: data, encoding: .utf8) else {
                        completionHandler(data, urlResponse, error)
                        return
                    }

                    // Parse the string into a workable HTML object
                    let html = try SwiftSoup.parse(htmlStr)

                    // Get the head of the HTML
                    guard let head = html.head() else {
                        completionHandler(data, urlResponse, error)
                        return
                    }

                    // Get all meta-refresh-redirect tag
                    let httpEquivs = try head.getElementsByAttribute("http-equiv")
                    guard let httpEquiv = try httpEquivs.whereAttr("http-equiv", equals: "refresh") else {
                        completionHandler(data, urlResponse, error)
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
                            completionHandler(data, urlResponse, error)
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
                            completionHandler(data, urlResponse, error)
                        }.resume()
                    }
                }
                catch {
                    completionHandler(data, urlResponse, error)
                    return
                }

            }
            // We're not supposed to check for the meta-refresh-redirect, so just return the data
            else {
                completionHandler(data, urlResponse, error)
            }
        }.resume()
    }

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
