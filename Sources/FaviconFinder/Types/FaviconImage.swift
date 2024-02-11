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

public struct Image {
    public var data: Data = .init()
}
#endif

public struct FaviconImage {

    // MARK: - Properties

    /// The data that makes up the actual image
    public let data: Data

    /// The platform-specific image
    public let image: Image

    // MARK: - Lifecycle

#if os(Linux)
    init(data: Data) throws {
        self.data = data
        self.image = Image()
    }
#else
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
    var size: CGFloat {
        return CGFloat(0)
    }
#else
    var size: CGFloat {
        return self.image.size.width * self.image.size.height
    }
#endif
}
