//
//  FaviconRelTypes.swift
//  FaviconFinder
//
//  Created by William Lumley on 16/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

import Foundation

public enum FaviconFormatType: String, CaseIterable, Equatable, Sendable {

    // HTML Types
    case appleTouchIcon            = "apple-touch-icon"
    case appleTouchIconPrecomposed = "apple-touch-icon-precomposed"
    case shortcutIcon              = "shortcut icon"
    case icon                      = "icon"

    // OpenGraphic Types
    case metaThumbnail             = "thumbnail"
    case metaOpenGraphImage        = "og:image"

    // Filetype (ico)
    case ico = "ico"

    // Web Application Manifest File
    // swiftlint:disable:next identifier_name
    case launcherIcon0_75x = "launcher-icon-0-75x.png"
    case launcherIcon1x    = "launcher-icon-1x.png"
    // swiftlint:disable:next identifier_name
    case launcherIcon1_5x  = "launcher-icon-1-5x.png"
    case launcherIcon2x    = "launcher-icon-2x.png"
    case launcherIcon3x    = "launcher-icon-3x.png"
    case launcherIcon4x    = "launcher-icon-4x.png"

}
