//
//  FaviconURL.swift
//  Pods
//
//  Created by William Lumley on 26/5/21.
//

import Foundation

struct FaviconURL {

    /// The url of the .ico or HTML page, of where the favicon was found
    public let url: URL

    /// The type of favicon we extracted
    public let type: FaviconType

}

extension FaviconURL {

    var emptyImage: Favicon {
        Favicon(
            image: FaviconImage(),
            data: Data(),
            url: self.url,
            type: self.type,
            downloadType: .html
        )
    }

}
