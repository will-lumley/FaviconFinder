//
//  Favicon.swift
//  Pods
//
//  Created by William Lumley on 26/5/21.
//

import Foundation

public struct Favicon {

    /// The actual image
    public let image: FaviconImage

    /// The data that makes up the actual image
    public let data: Data

    /// The url of the .ico or HTML page, of where the favicon was found
    public let url: URL

    /// The type of favicon we extracted
    public let type: FaviconType

    /// The download type of the favicon we extracted
    public let downloadType: FaviconDownloadType
}
