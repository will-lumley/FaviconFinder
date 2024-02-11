//
//  FaviconURL.swift
//  Pods
//
//  Created by William Lumley on 26/5/21.
//

import Foundation

public struct FaviconURL {
    /// The url of the .ico or HTML page, of where the favicon was found
    public let source: URL

    /// The type of favicon we extracted
    public let format: FaviconFormatType

    /// The source type of the favicon we extracted
    public let sourceType: FaviconSourceType

    /// If the size is from HTML and we've been told it's size, we'll store that data here
    public let sizeTag: String?
}
