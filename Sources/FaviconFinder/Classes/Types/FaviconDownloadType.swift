//
//  FaviconRelTypes.swift
//  FaviconFinder
//
//  Created by William Lumley on 16/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

import Foundation

public enum FaviconDownloadType {
    case html
    case ico
    case webApplicationManifestFile

    static let allTypes: [FaviconDownloadType] = [
        .html,
        .ico
    ]
}

internal extension FaviconDownloadType {

    init(type: FaviconType) {
        switch type {
        // ICO
        case .ico: self = .ico

        // HTML
        case .appleTouchIcon:            self = .html
        case .appleTouchIconPrecomposed: self = .html
        case .shortcutIcon:              self = .html
        case .icon:                      self = .html

        // Web Application Manifest File
        case .launcherIcon1x: self = .webApplicationManifestFile
        case .launcherIcon2x: self = .webApplicationManifestFile
        case .launcherIcon3x: self = .webApplicationManifestFile
        case .launcherIcon4x: self = .webApplicationManifestFile
        }
    }

}

internal extension FaviconDownloadType {

    func downloader(
        url: URL,
        preferredType: String?,
        checkForMetaRefreshRedirect: Bool,
        logEnabled: Bool
    ) -> FaviconFinderProtocol {
        switch self {
        case .ico:
            return ICOFaviconFinder(
                url: url,
                preferredType: preferredType,
                checkForMetaRefreshRedirect: checkForMetaRefreshRedirect,
                logEnabled: logEnabled
            )
        case .html:
            return HTMLFaviconFinder(
                url: url,
                preferredType: preferredType,
                checkForMetaRefreshRedirect: checkForMetaRefreshRedirect,
                logEnabled: logEnabled
            )
        case .webApplicationManifestFile:
            return WebApplicationManifestFaviconFinder(
                url: url,
                preferredType: preferredType,
                checkForMetaRefreshRedirect: checkForMetaRefreshRedirect,
                logEnabled: logEnabled
            )
        }
    }

}
