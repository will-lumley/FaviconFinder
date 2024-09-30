//
//  FaviconError.swift
//  FaviconFinder
//
//  Created by William Lumley on 16/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

import Foundation

/// `FaviconError` represents the various errors that can occur during the favicon fetching process.
///
/// This enumeration includes a variety of cases that capture issues ranging from data parsing
/// failures to favicon downloading errors. These errors help in diagnosing and handling
/// specific failure points within the `FaviconFinder` process.
///
public enum FaviconError: Error, Sendable {
    /// Indicates that no data was received during the download process.
    case emptyData

    /// Signals that the HTML of the page could not be parsed, which can happen if the HTML
    /// is malformed or the structure is not what was expected.
    case failedToParseHTML

    /// Occurs when no favicon could be found in any of the expected locations, such as
    /// the HTML head, a manifest file, or the root directory.
    case failedToFindFavicon

    /// Indicates that an attempt to download the favicon from a valid URL failed.
    case failedToDownloadFavicon

    /// Represents an error where the downloaded favicon data is empty, suggesting that
    /// something went wrong with the request or the resource is unavailable.
    case emptyFavicon

    /// The downloaded image could not be parsed into a valid image format, which could occur if
    /// the file is corrupted or is not a supported image format.
    case invalidImage

    /// A catch-all error for any other unspecified issues that may occur during the process.
    case other

    /// Specific error for when favicons are not found in the HTML document, even though the document
    /// could be successfully parsed.
    case failedToFindFaviconInHTML

    /// Occurs when the HTML head could not be parsed to locate favicons, which is often the section
    /// that contains links to icons in a webpage.
    case failedToParseHtmlHead

    /// Error indicating that a favicon image was attempted to be accessed, but the image was not yet downloaded.
    /// This is usually thrown if the `download()` function hasn't been called on a `FaviconURL` yet.
    case faviconImageIsNotDownloaded

    /// Indicates that the URL for the web application manifest file was invalid or could not be properly formed.
    case invalidWebApplicationManifestFileUrl

    /// This error occurs when the system fails to convert a URL response into an HTTP URL response, which
    /// can happen if the response is of an unexpected type or is malformed.
    case failedToConvertUrlResponseToHttpUrlResponse

    /// Occurs when the web application manifest file contains no icons, which means it does not define any
    /// images or favicons.
    case webApplicationManifestFileConainedNoIcons

    /// Could not find the web application manifest file in the HTML document, which may occur if
    /// the file is not linked correctly or missing.
    case failedToFindWebApplicationManifestFile

    /// Indicates that an attempt to download the web application manifest file failed, either due to
    /// network issues or an invalid URL.
    case failedToDownloadWebApplicationManifestFile

    /// The downloaded web application manifest file could not be parsed into a valid JSON structure,
    /// suggesting a possible issue with the file's formatting.
    case failedToParseWebApplicationManifestFile
}
