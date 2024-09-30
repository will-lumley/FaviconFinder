//
//  FaviconImage.swift
//
//
//  Created by William Lumley on 8/2/2024.
//

#if targetEnvironment(macCatalyst)
import UIKit
public typealias Image = UIImage

#elseif canImport(AppKit)
import AppKit
public typealias Image = NSImage

#elseif canImport(UIKit)
import UIKit
public typealias Image = UIImage

#elseif os(Linux)
import Foundation

/// A placeholder struct to represent an image on Linux, which does not natively support
/// image types like macOS and iOS.
public struct Image {
    public var data: Data = .init()
}
#endif

/// `FaviconImage` is a platform-agnostic struct that encapsulates the data and
/// platform-specific image representation of a favicon.
///
/// It supports `UIImage` for iOS and macOS, and provides a custom struct for Linux as
/// Linux does not natively support image types.
///
public struct FaviconImage: @unchecked Sendable {

    // MARK: - Properties

    /// The raw data that makes up the image.
    public let data: Data

    /// The platform-specific image type (e.g., `UIImage` for iOS, `NSImage` for macOS, or `Image` for Linux).
    public let image: Image

    // MARK: - Lifecycle

#if os(Linux)
    /// Initializes a `FaviconImage` instance for Linux.
    ///
    /// Since Linux does not have built-in image processing capabilities, the image is stored as raw data.
    /// - Parameter data: The raw image data.
    /// - Throws: No errors are thrown on Linux, but it initializes an empty `Image` struct.
    ///
    init(data: Data) throws {
        self.data = data
        self.image = Image()
    }
#else
    /// Initializes a `FaviconImage` instance for non-Linux platforms.
    ///
    /// This attempts to convert the raw image data into a platform-specific image (`UIImage` or `NSImage`).
    /// - Parameter data: The raw image data.
    /// - Throws: `FaviconError.invalidImage` if the image cannot be created from the data.
    ///
    init(data: Data) throws {
        guard let image = Image(data: data) else {
            throw FaviconError.invalidImage
        }

        self.data = data
        self.image = image
    }
#endif
}

extension FaviconImage {

#if os(Linux)
    /// Returns the size of the image.
    ///
    /// On Linux, the size is always 0 since images are not natively supported.
    /// On other platforms, it multiplies the width and height to give a total size.
    ///
    var size: CGFloat {
        return CGFloat(0)
    }
#else
    /// Returns the size of the image.
    ///
    /// On Linux, the size is always 0 since images are not natively supported.
    /// On other platforms, it multiplies the width and height to give a total size.
    /// 
    var size: CGFloat {
        return self.image.size.width * self.image.size.height
    }
#endif
}
