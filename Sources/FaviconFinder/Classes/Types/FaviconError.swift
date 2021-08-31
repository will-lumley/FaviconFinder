//
//  FaviconError.swift
//  FaviconFinder
//
//  Created by William Lumley on 16/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

import Foundation

public enum FaviconError: Error
{
    case emptyData
    case failedToParseHTML
    case failedToFindFavicon
    case failedToDownloadFavicon
    case emptyFavicon
    case invalidImage
    case other

    case failedToFindWebApplicationManifestFile
    case failedToDownloadWebApplicationManifestFile
    case failedToParseWebApplicationManifestFile
}
