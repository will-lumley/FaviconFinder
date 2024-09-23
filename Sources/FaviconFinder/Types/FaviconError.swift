//
//  FaviconError.swift
//  FaviconFinder
//
//  Created by William Lumley on 16/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

import Foundation

public enum FaviconError: Error, Sendable {
    case emptyData
    case failedToParseHTML
    case failedToFindFavicon
    case failedToDownloadFavicon
    case emptyFavicon
    case invalidImage
    case other

    case failedToFindFaviconInHTML
    case failedToParseHtmlHead

    case faviconImageIsNotDownloaded

    case invalidWebApplicationManifestFileUrl
    // swiftlint:disable:next identifier_name
    case failedToConvertUrlResponseToHttpUrlResponse

    // swiftlint:disable:next identifier_name
    case webApplicationManifestFileConainedNoIcons
    case failedToFindWebApplicationManifestFile

    // swiftlint:disable:next identifier_name
    case failedToDownloadWebApplicationManifestFile
    case failedToParseWebApplicationManifestFile
}
