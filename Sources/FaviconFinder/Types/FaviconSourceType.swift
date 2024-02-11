//
//  FaviconRelTypes.swift
//  FaviconFinder
//
//  Created by William Lumley on 16/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

import Foundation

public enum FaviconSourceType: CaseIterable, Sendable {
    case html
    case ico
    case webApplicationManifestFile
}

extension FaviconSourceType {

    init(format: FaviconFormatType) { 
        switch format {
        // ICO
        case .ico: self = .ico

        // HTML
        case .appleTouchIcon:            self = .html
        case .appleTouchIconPrecomposed: self = .html
        case .shortcutIcon:              self = .html
        case .icon:                      self = .html

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
        }
    }

}
