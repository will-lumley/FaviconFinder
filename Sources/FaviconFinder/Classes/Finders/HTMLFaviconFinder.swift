//
//  HTMLFaviconFinder.swift
//  Pods
//
//  Created by William Lumley on 26/5/21.
//

import Foundation

#if canImport(SwiftSoup)
import SwiftSoup
#endif

class HTMLFaviconFinder: FaviconFinderProtocol {

    // MARK: - Types

    struct HTMLFaviconReference {
        let rel: String
        let href: String
        let sizes: String?
    }

    // MARK: - Properties

    var url: URL
    var preferredType: String
    var checkForMetaRefreshRedirect: Bool

    var logEnabled: Bool
    var description: String
    var logger: Logger?

    /// When parsing through HTML, these are the type of images we'll look for in the HTML header
    private let acceptableIconTypes = FaviconType.allTypes

    // MARK: - FaviconFinder

    required init(url: URL, preferredType: String?, checkForMetaRefreshRedirect: Bool, logEnabled: Bool) {
        self.url = url
        self.preferredType = preferredType ?? FaviconType.appleTouchIcon.rawValue // Default to `appleTouchIcon` type if user does not present us with one
        self.checkForMetaRefreshRedirect = checkForMetaRefreshRedirect

        self.logEnabled = logEnabled
        self.description = NSStringFromClass(HTMLFaviconFinder.self)
        if logEnabled {
            self.logger = Logger(faviconFinder: self)
        }
    }

    func search() async throws -> FaviconURL {
        // Download the web page at our URL
        let urlResponse = try await FaviconURLRequest.dataTask(with: self.url, checkForMetaRefreshRedirect: self.checkForMetaRefreshRedirect)

        let data = urlResponse.0
        let response = urlResponse.1

        // Make sure we can parse the response into a string
        guard let html = String(data: data, encoding: response.encoding) else {
            throw FaviconError.failedToParseHTML
        }

        // Make sure we can find a favicon in our retrieved string (at this point we're assuming it's valid HTML)
        guard let faviconURL = self.faviconURL(from: html) else {
            throw FaviconError.failedToDownloadFavicon
        }

        // We found our favicon, let's download it
        Logger.print(self.logEnabled, "Extracted favicon: \(faviconURL.url.absoluteString)")

        return faviconURL
    }
}

// MARK: - Private Functions

private extension HTMLFaviconFinder {

    /**
     Parses the provided HTML for the favicon URL
     - parameter htmlStr: The HTML that we will be parsing and iterating through to find the favicon
     - returns: The URL that the favicon can be found at
    */
    func faviconURL(from htmlStr: String) -> FaviconURL? {
        var htmlOpt: Document?
        do {
            htmlOpt = try SwiftSoup.parse(htmlStr)
        }
        catch let error {
            self.logger?.print("Could NOT parse HTML due to error: \(error). HTML: \(htmlStr)")
            return nil
        }
        
        guard let html = htmlOpt else {
            self.logger?.print("Could NOT parse HTML from string: \(htmlStr)")
            return nil
        }
        
        guard let head = html.head() else {
            self.logger?.print("Could NOT parse HTML head from string: \(htmlStr)")
            return nil
        }

        // Where we're going to store our HTML favicons
        var possibleIcons = [HTMLFaviconReference]()

        var allLinks = Elements()
        do {
            allLinks = try head.select("link")
        }
        catch let error {
            self.logger?.print("Could NOT parse HTML due to error: \(error). HTML: \(htmlStr)")
            return nil
        }
        
        // Iterate over every 'link' tag that's in the head document, and collect them
        for element in allLinks {
            do {
                let rel = try element.attr("rel")
                let href = try element.attr("href")
                let sizes = try element.attr("sizes")
                
                //If this is an icon that we deem might be a favicon, add it to our array
                if FaviconType.contains(relTypes: self.acceptableIconTypes, rawRelType: rel) {
                    let possibleIcon = HTMLFaviconReference(rel: rel, href: href, sizes: sizes)
                    possibleIcons.append(possibleIcon)
                }
            }
            catch let error {
                self.logger?.print("Could NOT parse HTML due to error: \(error). HTML: \(htmlStr)")
                continue
            }
        }

        // Extract the most preferrable icon, and return it's href as a URL object
        guard let mostPreferrableIcon = self.mostPreferrableIcon(icons: possibleIcons) else {
            return nil
        }

        let href = mostPreferrableIcon.icon.href
        
        var hrefUrl: URL?

        // If we don't have a http or https prepended to our href, prepend our base domain
        if Regex.testForHttpsOrHttp(input: href) == false {
            let baseRef = {() -> URL in
                // Try and get the base URL from a HTML tag if we can
                if let baseRef = try? html.head()?.getElementsByTag("base").attr("href"), let baseRefUrl = URL(string: baseRef, relativeTo: self.url) {
                    return baseRefUrl
                }
                
                // We couldn't get the base URL from a HTML tag, so we'll use the base URL that we have on hand
                else {
                    return self.url
                }
            }

            hrefUrl = URL(string: href, relativeTo: baseRef())
        }
        
        // Our href is a proper URL, nevermind
        else {
            hrefUrl = URL(string: href)
        }
        
        guard let url = hrefUrl else {
            return nil
        }

        let faviconURL = FaviconURL(url: url, type: mostPreferrableIcon.type)
        return faviconURL
    }
    
    /**
     Returns the most desirable FaviconRelType from an array of FaviconRelType
     - parameter icons: Our array of our image links that we have to choose a desirable one from
     - returns: The most preferred image link from our aray of icons
     */
    func mostPreferrableIcon(icons: [HTMLFaviconReference]) -> (icon: HTMLFaviconReference, type: FaviconType)? {
        
        // Check for the users preferred type
        if let icon = icons.first(where: { FaviconType(rawValue: $0.rel)?.rawValue == preferredType }) {
            return (icon: icon, type: FaviconType(rawValue: icon.rel)!)
        }

        // Check for appleTouchIcon type
        else if let icon = icons.first(where: { FaviconType(rawValue: $0.rel) == .appleTouchIcon }) {
            return (icon: icon, type: FaviconType(rawValue: icon.rel)!)
        }

        // Check for appleTouchIconPrecomposed type
        else if let icon = icons.first(where: { FaviconType(rawValue: $0.rel) == .appleTouchIconPrecomposed }) {
            return (icon: icon, type: FaviconType(rawValue: icon.rel)!)
        }

        // Check for icon type
        let iconTypeIcons = icons.enumerated().filter({FaviconType(rawValue: $1.rel) == .icon})
        
        // Sort in sizes (like "64x64")
        let sizes = iconTypeIcons.map({ index, icon -> (index: Int, size: Int) in
            let iconSize = Int(icon.sizes?.components(separatedBy: "x").first ?? "") ?? 0
            return (index: index, size: iconSize)
        }).sorted(by: {$0.size > $1.size})

        if let firstSize = sizes.first {
            let icon = icons[firstSize.index]
            return (icon: icon, type: FaviconType(rawValue: icon.rel)!)
        }

        // Check for shortcutIcon type last since it's often a low quality .ico file
        if let icon = icons.first(where: { FaviconType(rawValue: $0.rel) == .shortcutIcon }) {
            return (icon: icon, type: FaviconType(rawValue: icon.rel)!)
        }

        return nil
    }

}
