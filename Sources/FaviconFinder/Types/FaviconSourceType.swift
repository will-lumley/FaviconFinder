//
//  FaviconRelTypes.swift
//  FaviconFinder
//
//  Created by William Lumley on 16/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

import Foundation

/// `FaviconSourceType` represents the different sources from which a favicon can be found.
public enum FaviconSourceType: Equatable, Sendable {
    /// Represents a favicon that is located in the HTML.
    case html

    /// Represents a favicon that is located as an `.ico` file in the server's root directory.
    case ico

    /// Represents a favicon that is located in a Web Application Manifest File.
    case webApplicationManifestFile

    /// Used exclusively for testing purposes, typically for mocking favicons.
    case mock

    /// Provides all available favicon source types.
    /// - Note: This intentionally excludes `.mock`.
    ///
    static var allCases: [FaviconSourceType] {
        [
            .html,
            .ico,
            .webApplicationManifestFile
        ]
    }

}

extension FaviconSourceType {

    /// Initializes a `FaviconSourceType` from a given `FaviconFormatType`.
    ///
    /// - Parameter format: The `FaviconFormatType` used to determine the source type.
    ///
    init(format: FaviconFormatType) {
        switch format {
        // ICO
        case .ico: self = .ico

        // HTML
        case .appleTouchIcon:            self = .html
        case .appleTouchIconPrecomposed: self = .html
        case .shortcutIcon:              self = .html
        case .icon:                      self = .html
        case .metaThumbnail:             self = .html
        case .metaOpenGraphImage:        self = .html

        // Web Application Manifest File
        case .launcherIcon0_75x: self = .webApplicationManifestFile
        case .launcherIcon1x: self = .webApplicationManifestFile
        case .launcherIcon1_5x: self = .webApplicationManifestFile
        case .launcherIcon2x: self = .webApplicationManifestFile
        case .launcherIcon3x: self = .webApplicationManifestFile
        case .launcherIcon4x: self = .webApplicationManifestFile
        }
    }

}

extension FaviconSourceType {

    /// Returns the appropriate `FaviconFinderProtocol` instance for the source type.
    ///
    /// - Parameters:
    ///   - url: The URL of the webpage being queried.
    ///   - configuration: The configuration used for finding the favicon.
    ///
    /// - Returns: An instance conforming to `FaviconFinderProtocol` based on the source type.
    /// 
    func finder(
        url: URL,
        configuration: FaviconFinder.Configuration
    ) -> FaviconFinderProtocol {
        switch self {
        case .ico:
            return ICOFaviconFinder(
                url: url,
                configuration: configuration
            )
        case .html:
            return HTMLFaviconFinder(
                url: url,
                configuration: configuration
            )
        case .webApplicationManifestFile:
            return WebApplicationManifestFaviconFinder(
                url: url,
                configuration: configuration
            )
        case .mock:
            return MockFaviconFinder(
                url: url,
                configuration: configuration
            )
        }
    }

}
