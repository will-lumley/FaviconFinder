//
//  FaviconFinder.swift
//  FaviconFinder
//
//  Created by William Lumley on 16/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//
#if targetEnvironment(macCatalyst)
import UIKit
public typealias FaviconImage = UIImage

#elseif canImport(AppKit)
import AppKit
public typealias FaviconImage = NSImage

#elseif canImport(UIKit)
import UIKit
public typealias FaviconImage = UIImage

#endif

#if canImport(SwiftSoup)
import SwiftSoup

#endif

public class FaviconFinder: NSObject {

    public struct Favicon {
        public let image: FaviconImage
        public let url: URL
    }

    // MARK: - Properties

    /// The base URL of the site we're trying to extract from
    private var url: URL
    
    /// If true, this means we failed to extract a favicon from the URL, and will now try to extract a favicon from the root domain
    private var usingRootUrl = false
    
    /// When parsing through HTML, these are the type of images we'll look for in the HTML header
    private var acceptableIconTypes = FaviconRelType.allTypes
    
    /// Prints useful states and errors when enabled
    private var isLogEnabled: Bool

    // MARK: - FaviconFinder

    public init(url: URL, isLogEnabled: Bool = false) {
        self.url = url
        self.isLogEnabled = isLogEnabled
    }
        
    /**
     Begins the quest to find our Favicon
     - parameter onCompletion: The closure that will be called when the image is found (or not found)
    */
    public func downloadFavicon(_ onCompletion: @escaping (_ result: Result<Favicon, FaviconError>) -> Void) {
        //Search for our favicon in the root directory
        self.searchForFaviconInRoot(onDownload: {result in
            
            switch result {
            case .success(let favicon):
                // We found a favicon in the root directory, we're done here
                DispatchQueue.main.async {
                    onCompletion(.success(favicon))
                }

            case .failure:
                //We failed to find the favicon in our root
                //Let's try and search our favicon in our HTML headers
                self.searchForFaviconInHTML(onDownload: {result in
                    
                    switch result {
                    case .success(let favicon):
                        DispatchQueue.main.async {
                            onCompletion(.success(favicon))
                        }

                    case .failure(let error):
                        DispatchQueue.main.async {
                            onCompletion(.failure(error))
                        }
                    }
                })
            }
        })
    }
    
    /**
     Searches for the favicon within the root directory of the website, with a filename of favicon.ico
     */
    private func searchForFaviconInRoot(onDownload: @escaping ((_ result: Result<Favicon, FaviconError>) -> Void)) {
        guard let faviconUrl = self.url.urlWithoutSubdomains?.appendingPathComponent("favicon.ico") else {
            onDownload(.failure(.failedToFindFavicon))
            return
        }
        
        self.downloadImage(at: faviconUrl, onDownload: onDownload)
    }
    
    /**
     Searches for a link to the favicon within the HTML header
     */
    private func searchForFaviconInHTML(onDownload: @escaping ((_ result: Result<Favicon, FaviconError>) -> Void)) {
        //Download the web page at our URL
        URLSession.shared.dataTask(with: self.url, completionHandler: {(data, response, error) in
            
            //Do some error checking
            if let error = error {
                self.handleDownloadError(error, onDownload)
                return
            }
            
            //Make sure our data exists
            guard let data = data else {
                if self.isLogEnabled {
                    print("Could NOT get favicon from url: \(self.url), Data was nil.")
                }
                onDownload(.failure(.emptyData))
                return
            }
            
            //Make sure we can parse the response into a string
            guard let html = String(data: data, encoding: String.Encoding.utf8) else {
                if self.isLogEnabled {
                    print("Could NOT get favicon from url: \(self.url), could not parse HTML.")
                }
                onDownload(.failure(.failedToParseHTML))
                return
            }
            
            //Make sure we can find a favicon in our retrieved string (at this point we're assuming it's valid HTML)
            guard let url = self.faviconURL(from: html) else {
                if self.isLogEnabled {
                    print("Could NOT get favicon from url: \(self.url), failed to parse favicon from HTML.")
                }
                onDownload(.failure(.failedToDownloadFavicon))
                return
            }
            
            //We found our favicon, let's download it
            if self.isLogEnabled {
                print("Extracted favicon: \(url.absoluteString)")
            }

            self.downloadImage(at: url, onDownload: onDownload)
            
        }).resume()
    }
        
    /**
     Downloads an image from the provided URL
     - parameter url: The URL at which we assume an image is at
     */
    private func downloadImage(at url: URL, onDownload: @escaping ((_ result: Result<Favicon, FaviconError>) -> Void)) {
        //Now that we've got the URL of the image, let's download the image
        URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
            if let error = error {
                if self.isLogEnabled {
                    print("Could NOT download favicon from url: \(url), error: \(error)")
                }
                onDownload(.failure(.failedToDownloadFavicon))

                return
            }
            
            //Make sure our data exists
            guard let data = data else {
                if self.isLogEnabled {
                    print("Could NOT get favicon from url: \(self.url), Data was nil.")
                }
                onDownload(.failure(.emptyFavicon))

                return
            }
            
            guard let image = FaviconImage(data: data) else {
                if self.isLogEnabled {
                    print("Could NOT create favicon from data.")
                }
                onDownload(.failure(.invalidImage))
                
                return
            }
            
            if self.isLogEnabled {
                print("Successfully extracted favicon from url: \(self.url)")
            }

            let favicon = Favicon(image: image, url: url)
            onDownload(.success(favicon))
            
        }).resume()
    }
    
    /**
     This function gets called If we fail to get connect to our URL
     - parameter error: The error that tells us why we couldn't connect to the URL
     */
    private func handleDownloadError(_ error: Error, _ onDownload: @escaping ((_ result: Result<Favicon, FaviconError>) -> Void)) {
        //We've already tried to fix the URL, don't bother again
        if self.usingRootUrl {
            onDownload(.failure(.other))
            return
        }
        
        //If we can extract a root URL, try again
        if let newURL = self.url.urlWithoutSubdomains {
            self.usingRootUrl = true
            
            self.url = newURL
            self.downloadFavicon(onDownload)
        }
        else {
            onDownload(.failure(.other))
        }
    }
}

//MARK: - HTML Parsing
private extension FaviconFinder
{
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
            if isLogEnabled {
                print("Could NOT parse HTML due to error: \(error). HTML: \(htmlStr)")
            }
            return nil
        }
        
        guard let html = htmlOpt else {
            if isLogEnabled {
                print("Could NOT parse HTML from string: \(htmlStr)")
            }
            return nil
        }
        
        guard let head = html.head() else {
            if isLogEnabled {
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
            if isLogEnabled {
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
                if FaviconRelType.contains(relTypes: self.acceptableIconTypes, rawRelType: rel) {
                    let possibleIcon = (rel: rel, href: href)
                    possibleIcons.append(possibleIcon)
                }
            }
            catch let error {
                if isLogEnabled {
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
        return icons.first(where: { rel, _ in rel == FaviconRelType.appleTouchIcon.rawValue }) ??
            icons.first(where: { rel, _ in rel == FaviconRelType.appleTouchIconPrecomposed.rawValue }) ??
            icons.first(where: { rel, _ in rel == FaviconRelType.shortcutIcon.rawValue }) ??
            icons.first(where: { rel, _ in rel == FaviconRelType.icon.rawValue })
    }
}
