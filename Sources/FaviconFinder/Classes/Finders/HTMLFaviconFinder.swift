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

    var url: URL
    var logEnabled: Bool

    /// When parsing through HTML, these are the type of images we'll look for in the HTML header
    private var acceptableIconTypes = FaviconType.allTypes

    required init(url: URL, logEnabled: Bool) {
        self.url = url
        self.logEnabled = logEnabled
    }

    func search(onFind: @escaping ((Result<URL, FaviconError>) -> Void)) {

        //Download the web page at our URL
        URLSession.shared.dataTask(with: self.url, completionHandler: {(data, response, error) in
            
            //Make sure our data exists
            guard let data = data else {
                if self.logEnabled {
                    print("Could NOT get favicon from url: \(self.url), Data was nil.")
                }
                onFind(.failure(.emptyData))
                return
            }
            
            //Make sure we can parse the response into a string
            guard let html = String(data: data, encoding: String.Encoding.utf8) else {
                if self.logEnabled {
                    print("Could NOT get favicon from url: \(self.url), could not parse HTML.")
                }
                onFind(.failure(.failedToParseHTML))
                return
            }
            
            //Make sure we can find a favicon in our retrieved string (at this point we're assuming it's valid HTML)
            guard let url = self.faviconURL(from: html) else {
                if self.logEnabled {
                    print("Could NOT get favicon from url: \(self.url), failed to parse favicon from HTML.")
                }
                onFind(.failure(.failedToDownloadFavicon))
                return
            }
            
            //We found our favicon, let's download it
            if self.logEnabled {
                print("Extracted favicon: \(url.absoluteString)")
            }

            onFind(.success(url))
            
        }).resume()
    }

}

private extension HTMLFaviconFinder {

    /**
     Parses the provided HTML for the favicon URL
     - parameter htmlStr: The HTML that we will be parsing and iterating through to find the favicon
     - returns: The URL that the favicon can be found at
    */
    func faviconURL(from htmlStr: String) -> URL? {
        var htmlOpt: Document?
        do {
            htmlOpt = try SwiftSoup.parse(htmlStr)
        }
        catch let error {
            if logEnabled {
                print("Could NOT parse HTML due to error: \(error). HTML: \(htmlStr)")
            }
            return nil
        }
        
        guard let html = htmlOpt else {
            if logEnabled {
                print("Could NOT parse HTML from string: \(htmlStr)")
            }
            return nil
        }
        
        guard let head = html.head() else {
            if logEnabled {
                print("Could NOT parse HTML head from string: \(htmlStr)")
            }
            return nil
        }
        
        var possibleIcons = [(rel: String, href: String)]()
        
        var allLinks = Elements()
        do {
            allLinks = try head.select("link")
        }
        catch let error {
            if logEnabled {
                print("Could NOT parse HTML due to error: \(error). HTML: \(htmlStr)")
            }
            return nil
        }
        
        //Iterate over every 'link' tag that's in the head document, and collect them
        for element in allLinks {
            do {
                let rel = try element.attr("rel")
                let href = try element.attr("href")
                
                //If this is an icon that we deem might be a favicon, add it to our array
                if FaviconType.contains(relTypes: self.acceptableIconTypes, rawRelType: rel) {
                    let possibleIcon = (rel: rel, href: href)
                    possibleIcons.append(possibleIcon)
                }
            }
            catch let error {
                if logEnabled {
                    print("Could NOT parse HTML due to error: \(error). HTML: \(htmlStr)")
                }
                continue
            }
        }
        
        //Extract the most preferrable icon, and return it's href as a URL object
        let mostPreferrableIcon = self.mostPreferrableIcon(icons: possibleIcons)
        
        guard let href = mostPreferrableIcon?.href else { return nil }
        
        //If we don't have a http or https prepended to our href, prepend our base domain
        if !Regex.testForHttpsOrHttp(input: href) {
            let host   = "\(self.url.scheme ?? "https")://"
            let domain = self.url.host ?? self.url.absoluteString
            return URL(string: "\(host)\(domain)")?.appendingPathComponent(href)
        }
        
        return URL(string: href)
    }
    
    /**
     Returns the most desirable FaviconRelType from an array of FaviconRelType
     - parameter icons: Our array of our image links that we have to choose a desirable one from
     - returns: The most preferred image link from our aray of icons
     */
    func mostPreferrableIcon(icons: [(rel: String, href: String)]) -> (rel: String, href: String)? {
        return icons.first(where: { rel, _ in rel == FaviconType.appleTouchIcon.rawValue }) ??
            icons.first(where: { rel, _ in rel == FaviconType.appleTouchIconPrecomposed.rawValue }) ??
            icons.first(where: { rel, _ in rel == FaviconType.shortcutIcon.rawValue }) ??
            icons.first(where: { rel, _ in rel == FaviconType.icon.rawValue })
    }

}
