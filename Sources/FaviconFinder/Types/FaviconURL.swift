//
//  FaviconURL.swift
//  Pods
//
//  Created by William Lumley on 26/5/21.
//

import Foundation

public struct FaviconURL: Sendable {

    /// The url of the .ico or HTML page, of where the favicon was found
    public let source: URL

    /// The type of favicon we extracted
    public let format: FaviconFormatType

    /// The source type of the favicon we extracted
    public let sourceType: FaviconSourceType

    /// If the icon is from HTML/WAMF and we've been told it's size, we'll store that data here
    public let sizeTag: String?

    /// Using the `sizeTag` this will return the indicated size of the image located at the URL.
    /// If `sizeTag` is `nil`, then `nil` will be returned.
    ///
    /// - returns: The CGSize that is indicated in the `sizeTag`
    ///
    public var inferredSize: CGSize? {
        // Split the size tag components into their individual numbers
        guard let components = self.sizeTag?.split(separator: "x") else {
            return nil
        }

        // Make sure we only got two components, or something has gone very wrong
        guard components.count == 2 else {
            return nil
        }

        // Grab the sizes as strings
        let widthStr = components[0]
        let heightStr = components[1]

        // Let's convert those strings into doubles
        guard let width = Double(widthStr), let height = Double(heightStr) else {
            return nil
        }

        // Wrap it up in a pretty ~bow~ CGSize
        return .init(width: width, height: height)
    }
}
