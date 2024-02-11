//
//  Image+Validation.swift
//
//
//  Created by William Lumley on 11/2/2024.
//

import Foundation
@testable import FaviconFinder

extension FaviconImage {

    var isValidImage: Bool {
        #if targetEnvironment(macCatalyst)
        return self.image.isValid

        #elseif canImport(AppKit)
        return self.image.isValid

        #elseif canImport(UIKit)
        return self.image.cgImage != nil || self.image.ciImage != nil

        #else // Linux and other non-Apple platforms
        return true // We'll leave this hardcoded as we Linux doesn't have an "image" type

        #endif
    }

}
