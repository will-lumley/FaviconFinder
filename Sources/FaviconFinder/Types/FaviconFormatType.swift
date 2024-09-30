//
//  FaviconRelTypes.swift
//  FaviconFinder
//
//  Created by William Lumley on 16/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

import Foundation

public enum FaviconFormatType: String, CaseIterable, Equatable, Sendable {

    // MARK: - HTML Types

    /// Represents the `apple-touch-icon` link, commonly used for iOS and Apple devices.
    case appleTouchIcon = "apple-touch-icon"

    /// Represents the `apple-touch-icon-precomposed` link, which prevents iOS from adding effects like
    /// gloss and rounded corners, useful when the favicon is already styled.
    case appleTouchIconPrecomposed = "apple-touch-icon-precomposed"

    /// Refers to the `shortcut icon` link, an older but still supported way of declaring favicons.
    case shortcutIcon = "shortcut icon"

    /// The generic `icon` link, which is the most common way to declare favicons in HTML.
    case icon = "icon"

    // MARK: - OpenGraph Types

    /// Represents the `thumbnail` meta tag, commonly used in social media platforms like Facebook or Twitter
    /// to provide a small image for sharing links.
    case metaThumbnail = "thumbnail"

    /// Refers to the `og:image` OpenGraph meta tag, which is used to specify the image associated with a URL
    /// for rich previews in social media and chat applications.
    case metaOpenGraphImage = "og:image"

    // MARK: - File Types

    /// Represents the `.ico` file format, typically used for favicons that are directly linked or in the
    /// root of the website (e.g., `favicon.ico`).
    case ico = "ico"

    // MARK: - Web Application Manifest File Types

    /// Represents the `launcher-icon-0-75x.png` in a Web Application Manifest File, which is used in
    /// progressive web apps for icons at different scales.
    case launcherIcon0_75x = "launcher-icon-0-75x.png" // swiftlint:disable:this identifier_name

    /// Represents the `launcher-icon-1x.png` in a Web Application Manifest File, for icons used at 1x scale.
    case launcherIcon1x = "launcher-icon-1x.png"

    /// Represents the `launcher-icon-1-5x.png` in a Web Application Manifest File, for icons used at 1.5x scale.
    case launcherIcon1_5x = "launcher-icon-1-5x.png" // swiftlint:disable:this identifier_name

    /// Represents the `launcher-icon-2x.png` in a Web Application Manifest File, for icons used at 2x scale.
    case launcherIcon2x = "launcher-icon-2x.png"

    /// Represents the `launcher-icon-3x.png` in a Web Application Manifest File, for icons used at 3x scale.
    case launcherIcon3x = "launcher-icon-3x.png"

    /// Represents the `launcher-icon-4x.png` in a Web Application Manifest File, for icons used at 4x scale.
    case launcherIcon4x = "launcher-icon-4x.png"

}
