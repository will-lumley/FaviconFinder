//
//  FaviconRelTypes.swift
//  FaviconFinder
//
//  Created by William Lumley on 16/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

import Foundation

internal enum FaviconDownloadType {
    case html
    case ico
    case rootIco

    static let allTypes: [FaviconDownloadType] = [
        .html,
        .ico,
        .rootIco
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

    func downloader(url: URL, logEnabled: Bool) -> FaviconFinderProtocol {
        switch self {
        case .ico:
            return ICOFaviconFinder(url: url, logEnabled: logEnabled)
        case .rootIco:
            return RootICOFaviconFinder(url: url, logEnabled: logEnabled)
        case .html:
            return HTMLFaviconFinder(url: url, logEnabled: logEnabled)
        }
    }

}
