//
//  FaviconFinder.swift
//  FaviconFinder
//
//  Created by William Lumley on 16/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

#if os(OSX)
import AppKit
public typealias Image = NSImage

#elseif os(iOS)
import UIKit
public typealias Image = UIImage

#endif

#if canImport(SwiftSoup)
import SwiftSoup

#endif

open class FaviconFinder: NSObject
{
    ///The base URL of the site we're trying to extract from
    fileprivate var url: URL
    
    ///If true, this means we failed to extract a favicon from the URL, and will now try to extract a favicon from the root domain
    fileprivate var usingRootUrl = false
    
    ///When parsing through HTML, these are the type of images we'll look for in the HTML header
    fileprivate var acceptableIconTypes = FaviconRelType.allTypes
    
    public init(url: URL)
    {
        self.url = url
    }
        
    /**
     Begins the quest to find our Favicon
     - parameter onCompletion: The closure that will be called when the image is found (or not found)
    */
    public func downloadFavicon(_ onCompletion: @escaping (_ image: Image?, _ error: Error?) -> Void)
    {
        //Search for our favicon in the root directory
        self.searchForFaviconInRoot(onDownload: {(image, error) in
            
            //We failed to find the favicon in our root
            if error != nil {
                
                //Let's try and search our favicon in our HTML headers
                self.searchForFaviconInHTML(onDownload: {(image, error) in
                    
                    //We failed to find the favicon in the HTML as well
                    if let error = error {
                        DispatchQueue.main.async(execute: { onCompletion(nil, error) })
                        
                        return
                    }
                    
                    //We didn't experience an error when download our favicon in our HTML header
                    else {
                        //We found an image, yay
                        if let image = image {
                            DispatchQueue.main.async(execute: { onCompletion(image, nil) })
                            
                        }
                        //We failed to create an image
                        else {
                            DispatchQueue.main.async(execute: { onCompletion(nil, FaviconError.invalidImage) })
                        }
                    }
                })
            }
            
            //We didn't experience an error when downloading our root favicon
            else {
                //We found an image, yay
                if let image = image {
                    DispatchQueue.main.async(execute: { onCompletion(image, nil) })
                }
                //We failed to create an image
                else {
                    DispatchQueue.main.async(execute: { onCompletion(nil, FaviconError.invalidImage) })
                }
            }
        })
    }
    
    /**
     Searches for the favicon within the root directory of the website, with
     a filename of favicon.ico
     */
    fileprivate func searchForFaviconInRoot(onDownload: @escaping ((_ image: Image?, _ error: Error?) -> Void))
    {
        guard let faviconUrl = self.url.urlWithoutSubdomains()?.appendingPathComponent("favicon.ico") else {
            onDownload(nil, FaviconError.failedToFindFavicon)
            return
        }
        
        self.downloadImage(at: faviconUrl, onDownload: onDownload)
    }
    
    /**
     Searches for a link to the favicon within the HTML header
     */
    fileprivate func searchForFaviconInHTML(onDownload: @escaping ((_ image: Image?, _ error: Error?) -> Void))
    {
        //Download the web page at our URL
        URLSession.shared.dataTask(with: self.url, completionHandler: {(data, response, error) in
            
            //Do some error checking
            if let error = error {
                self.handleDownloadError(error, onDownload)
                return
            }
            
            //Make sure our data exists
            guard let data = data else {
                print("Could NOT get favicon from url: \(self.url), Data was nil.")
                onDownload(nil, FaviconError.emptyData)
                return
            }
            
            //Make sure we can parse the response into a string
            guard let html = String(data: data, encoding: String.Encoding.utf8) else {
                print("Could NOT get favicon from url: \(self.url), could not parse HTML.")
                onDownload(nil, FaviconError.failedToParseHTML)
                return
            }
            
            //Make sure we can find a favicon in our retrieved string (at this point we're assuming it's valid HTML)
            guard let url = self.faviconURL(from: html) else {
                print("Could NOT get favicon from url: \(self.url), failed to parse favicon from HTML.")
                onDownload(nil, FaviconError.failedToFindFavicon)
                return
            }
            
            //We found our favicon, let's download it
            print("Extracted favicon: \(url.absoluteString)")
            self.downloadImage(at: url, onDownload: onDownload)
            
        }).resume()
    }
        
    /**
     Downloads an image from the provided URL
     - parameter url: The URL at which we assume an image is at
     */
    fileprivate func downloadImage(at url: URL, onDownload: @escaping ((_ image: Image?, _ error: Error?) -> Void))
    {
        //Now that we've got the URL of the image, let's download the image
        URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
            if let error = error {
                print("Could NOT download favicon from url: \(url), error: \(error)")
                onDownload(nil, FaviconError.failedToDownloadFavicon)
                
                return
            }
            
            //Make sure our data exists
            guard let data = data else {
                print("Could NOT get favicon from url: \(self.url), Data was nil.")
                onDownload(nil, FaviconError.emptyFavicon)
                
                return
            }
            
            guard let image = Image(data: data) else {
                print("Could NOT create favicon from data.")
                onDownload(nil, FaviconError.invalidImage)
                
                return
            }
            
            print("Successfully extracted favicon from url: \(self.url)")
            onDownload(image, nil)
            
        }).resume()
    }
    
    /**
     This function gets called If we fail to get connect to our URL
     - parameter error: The error that tells us why we couldn't connect to the URL
     */
    fileprivate func handleDownloadError(_ error: Error, _ onDownload: @escaping ((_ image: Image?, _ error: Error?) -> Void))
    {
        //We've already tried to fix the URL, don't bother again
        if self.usingRootUrl {
            onDownload(nil, error)
            return
        }
        
        //If we can extract a root URL, try again
        if let newURL = self.url.urlWithoutSubdomains() {
            self.usingRootUrl = true
            
            self.url = newURL
            self.downloadFavicon(onDownload)
        }
        else {
            onDownload(nil, error)
        }
    }
}

//MARK: - HTML Parsing
extension FaviconFinder
{
    /**
     Parses the provided HTML for the favicon URL
     - parameter htmlStr: The HTML that we will be parsing and iterating through to find the favicon
     - returns: The URL that the favicon can be found at
    */
    fileprivate func faviconURL(from htmlStr: String) -> URL?
    {
        var htmlOpt: Document?
        do {
            htmlOpt = try SwiftSoup.parse(htmlStr)
        }
        catch let error {
            print("Could NOT parse HTML due to error: \(error). HTML: \(htmlStr)")
            return nil
        }
        
        guard let html = htmlOpt else {
            print("Could NOT parse HTML from string: \(htmlStr)")
            return nil
        }
        
        guard let head = html.head() else {
            print("Could NOT parse HTML head from string: \(htmlStr)")
            return nil
        }
        
        var possibleIcons = [(rel: String, href: String)]()
        
        var allLinks = Elements()
        do {
            allLinks = try head.select("link")
        }
        catch let error {
            print("Could NOT parse HTML due to error: \(error). HTML: \(htmlStr)")
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
                print("Could NOT parse HTML due to error: \(error). HTML: \(htmlStr)")
                continue
            }
        }
        
        //Extract the most preferrable icon, and return it's href as a URL object
        let mostPreferrableIcon = self.mostPreferrableIcon(icons: possibleIcons)
        
        guard var href = mostPreferrableIcon?.href else { return nil }
        
        //If we don't have a http or https prepended to our href, prepend our base domain
        if !Regex.testForHttpsOrHttp(input: href) {
            let host   = "\(self.url.scheme ?? "https")://"
            let domain = self.url.host ?? self.url.absoluteString
            href = "\(host)\(domain)\(href)"
        }
        
        return URL(string: href)
    }
    
    /**
     Returns the most desirable FaviconRelType from an array of FaviconRelType
     - parameter icons: Our array of our image links that we have to choose a desirable one from
     - returns: The most preferred image link from our aray of icons
     */
    fileprivate func mostPreferrableIcon(icons: [(rel: String, href: String)]) -> (rel: String, href: String)?
    {
        for icon in icons {
            let rel  = icon.rel
            
            switch rel {
            case FaviconRelType.appleTouchIcon.rawValue:
                return icon

            case FaviconRelType.appleTouchIconPrecomposed.rawValue:
                return icon

            case FaviconRelType.shortcutIcon.rawValue:
                return icon
                
            case FaviconRelType.icon.rawValue:
                return icon
                
            default:
                print("Not using link rel: \(rel)")
            }
        }
        
        return nil
    }
}
