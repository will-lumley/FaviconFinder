//
//  FaviconURL.swift
//  Pods
//
//  Created by William Lumley on 26/5/21.
//

import Foundation

internal struct FaviconURL {

    /// The url of the .ico or HTML page, of where the favicon was found
    public let url: URL

    /// The type of favicon we extracted
    public let type: FaviconType

}
