//
//  Size.swift
//  FaviconFinder
//
//  Created by William Lumley on 26/9/2024.
//

/// `FaviconSize` represents the dimensions of a favicon image, including its width and height.
/// We use this instead of `CGSize` when referring to an images size, as certain pain points are introduced
/// when trying to use import `CoreGraphics` when using `Linux`.
///
public struct FaviconSize: Equatable, Sendable {

    // MARK: - Properties

    /// The width of the favicon image.
    public let width: Double

    /// The height of the favicon image.
    public let height: Double

    // MARK: - Lifecycle

    /// Initializes a `FaviconSize` instance with specified width and height.
    ///
    /// - Parameters:
    ///   - width: The width of the image.
    ///   - height: The height of the image.
    ///
    init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }

    /// Initializes a `FaviconSize` instance by converting string representations of width and height.
    ///
    /// If the strings cannot be converted into valid `Double` values, initialization will fail.
    ///
    /// - Parameters:
    ///   - widthStr: The string representation of the width.
    ///   - heightStr: The string representation of the height.
    /// - Returns: An optional `FaviconSize`, or `nil` if the strings are not valid `Double` values.
    ///
    init?(widthStr: String, heightStr: String) {
        guard
            let width = Double(widthStr),
            let height = Double(heightStr) else {
            return nil
        }

        self.width = width
        self.height = height
    }

}

// MARK: - Public

public extension FaviconSize {

    /// The overall dimension of the favicon, calculated by multiplying the width and height.
    ///
    /// This can be useful for determining the relative size of the favicon compared to others.
    /// 
    var dimension: Double {
        self.width * self.height
    }

}
