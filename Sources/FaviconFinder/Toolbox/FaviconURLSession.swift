//
//  FaviconURLSession.swift
//  Pods
//
//  Created by William Lumley on 5/3/2022.
//

#if os(Linux)
import FoundationNetworking
#endif

import Foundation
import SwiftSoup

/// Why is having our own wrapper around `URLSession` necessary? Great question. Usually I'd be very against
/// something like this, but I believe that in this use-case it's necessary for a number of reasons.
///
/// 1. Having all our Favicon download's come through this object allows for us to check for a meta-refresh redirect. `URLSession`
/// doesn't check for meta-refresh redirect's so having it here allows for the caller to not worry about such logic.
///
/// 2. The `URLSession` that comes with Linux (ie. `FoundationNetworking`) doesn't support `async await`
/// functionality, instead relying on archaic closures. Having this handled in `FaviconURLRequest` is neat so the
/// caller doesn't have to worry about handling the two different types of `URLSession` calls.
///
class FaviconURLSession {
    
    // MARK: - Types

    struct Response {
        let data: Data
        let rawResponse: URLResponse
        
        init(_ rawResponse: (Data, URLResponse)) {
            self.data = rawResponse.0
            self.rawResponse = rawResponse.1
        }
    }

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
        return try await withCheckedThrowingContinuation { continuation in
            let urlRequest = URLRequest(url: url)
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, rawResponse, error in
                guard let data else {
                    continuation.resume(throwing: FaviconError.failedToDownloadFavicon)
                    return
                }
                guard let rawResponse else {
                    continuation.resume(throwing: FaviconError.failedToDownloadFavicon)
                    return
                }

                let response = Response((data, rawResponse))
                
                if checkForMetaRefreshRedirect {
                    // Make sure we can parse the response into a string
                    guard let htmlStr = String(data: data, encoding: rawResponse.encoding) else {
                        continuation.resume(returning: response)
                        return
                    }

                    // Parse the string into a workable HTML object
                    guard let html = try? SwiftSoup.parse(htmlStr) else {
                        continuation.resume(returning: response)
                        return
                    }
                    
                    // Get the head of the HTML
                    guard let head = html.head() else {
                        continuation.resume(returning: response)
                        return
                    }
                    
                    // Get all meta-refresh-redirect tag
                    guard let httpEquivs = try? head.getElementsByAttribute("http-equiv") else {
                        continuation.resume(returning: response)
                        return
                    }
                    guard let httpEquiv = try? httpEquivs.whereAttr("http-equiv", equals: "refresh") else {
                        continuation.resume(returning: response)
                        return
                    }
                    
                    // Get the URL
                    guard var redirectURLStr = try? httpEquiv.attr("content") else {
                        continuation.resume(returning: response)
                        return
                    }
                    
                    // Remove the 0;URL=
                    redirectURLStr = redirectURLStr.replacingOccurrences(of: "0;URL=", with: "")
                    
                    // Determine if this is a whole new URL, or something we should append to the current one
                    let brandNewURL = Regex.testForHttpsOrHttp(input: redirectURLStr)
                    
                    // If this is a brand new URL
                    if brandNewURL {
                        // If we can't form a valid redirect URL, we'll just return the data from the original page
                        guard let redirectURL = URL(string: redirectURLStr) else {
                            continuation.resume(returning: response)
                            return
                        }

                        URLSession.shared.dataTask(with: URLRequest(url: redirectURL)) { redirectData, redirectRawResponse, redirectError in
                            guard let redirectData else {
                                continuation.resume(throwing: FaviconError.failedToDownloadFavicon)
                                return
                            }
                            guard let redirectRawResponse else {
                                continuation.resume(throwing: FaviconError.failedToDownloadFavicon)
                                return
                            }

                            let redirectResponse = Response((redirectData, redirectRawResponse))
                            continuation.resume(returning: redirectResponse)
                        }
                        .resume()
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
                            continuation.resume(returning: response)
                            return
                        }
                        
                        URLSession.shared.dataTask(with: URLRequest(url: redirectURL)) { redirectData, redirectRawResponse, redirectError in
                            guard let redirectData else {
                                continuation.resume(throwing: FaviconError.failedToDownloadFavicon)
                                return
                            }
                            guard let redirectRawResponse else {
                                continuation.resume(throwing: FaviconError.failedToDownloadFavicon)
                                return
                            }

                            let redirectResponse = Response((redirectData, redirectRawResponse))
                            continuation.resume(returning: redirectResponse)
                        }
                        .resume()
                    }
                }
                // We're not supposed to check for the meta-refresh-redirect, so just return the data
                else {
                    continuation.resume(returning: response)
                    return
                }
            }

            dataTask.resume()
        }
    }

#else

    static func appleDataTask(
        with url: URL,
        checkForMetaRefreshRedirect: Bool = false
    ) async throws -> Response {
        let response = Response(try await URLSession.shared.data(from: url))

        let data = response.data
        let rawResponse = response.rawResponse

        if checkForMetaRefreshRedirect {
            // Make sure we can parse the response into a string
            guard let htmlStr = String(data: data, encoding: rawResponse.encoding) else {
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
                }
                else {
                    redirectURLStr = "\(url.absoluteString)\(redirectURLStr)"
                }
                
                // If we can't form a valid redirect URL, we'll just return the data from the original page
                guard let redirectURL = URL(string: redirectURLStr) else {
                    return response
                }
                
                let redirectResponse = Response(try await URLSession.shared.data(from: redirectURL))
                return redirectResponse
            }
        }
        // We're not supposed to check for the meta-refresh-redirect, so just return the data
        else {
            return response
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
