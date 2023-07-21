//
//  FaviconRelTypes.swift
//  FaviconFinder
//
//  Created by William Lumley on 16/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

import Foundation

public enum FaviconType: String {

    // HTML Types
    case appleTouchIcon            = "apple-touch-icon"
    case appleTouchIconPrecomposed = "apple-touch-icon-precomposed"
    case shortcutIcon              = "shortcut icon"
    case icon                      = "icon"

    // Filetype (ico)
    case ico = "ico"

    // Web Application Manifest File
    case launcherIcon1x = "launcher-icon-1x.png"
    case launcherIcon2x = "launcher-icon-2x.png"
    case launcherIcon3x = "launcher-icon-3x.png"
    case launcherIcon4x = "launcher-icon-4x.png"

    static let allTypes: [FaviconType] = [
        .appleTouchIcon,
        .appleTouchIconPrecomposed,
        .shortcutIcon,
        .icon,

        .ico,

        .launcherIcon1x,
        .launcherIcon2x,
        .launcherIcon3x,
        .launcherIcon4x,
    ]
}

internal extension FaviconType {

    /**
     Checks to see if the provided rawRelType matches to an enum provided in the array
     of FaviconRelTypes
     - parameter relTypes: An array of FaviconRelTypes, that we'll check against the provided rawRelType
     - parameter rawRelType: A raw string representation of a FaviconRelType. We'll iterate through our array of relTypes and look for a match
     - returns: A boolean value indicative of if rawRelType was found in relTypes
     */
    static func contains(relTypes: [FaviconType], rawRelType: String) -> Bool {
        guard let needle = FaviconType(rawValue: rawRelType) else {
            return false
        }
        
        for relType in relTypes {
            if relType == needle {
                return true
            }
        }
        
        return false
    }

}
