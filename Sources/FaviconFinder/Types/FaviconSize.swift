//
//  Size.swift
//  FaviconFinder
//
//  Created by William Lumley on 26/9/2024.
//

public struct FaviconSize: Equatable, Sendable {

    // MARK: - Properties

    public let width: Double
    public let height: Double

    // MARK: - Lifecycle

    init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }

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

    var dimension: Double {
        self.width * self.height
    }

}
