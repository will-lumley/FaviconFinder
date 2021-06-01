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

    static let allTypes: [FaviconDownloadType] = [
        .html,
        .ico
    ]
}

internal extension FaviconDownloadType {

    init(type: FaviconType) {
        switch type {
        case .ico:
            self = .ico
        default:
            self = .html
        }
    }

}

internal extension FaviconDownloadType {

    func downloader(url: URL, preferredType: String?, logEnabled: Bool) -> FaviconFinderProtocol {
        switch self {
        case .ico:
            return ICOFaviconFinder(url: url, preferredType: preferredType, logEnabled: logEnabled)
        case .html:
            return HTMLFaviconFinder(url: url, preferredType: preferredType, logEnabled: logEnabled)
        }
    }

}
