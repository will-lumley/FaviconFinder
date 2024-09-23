//
//  TestURL.swift
//
//
//  Created by William Lumley on 13/8/2024.
//

import Foundation
import Testing

enum TestURL: CaseIterable {
    case google
    case apple
    case w3Schools
    case realFaviconGenerator
    case webApplicationManifest
    case metaRefreshRedirect
    case nonUtf8Encoded
    case plinky
}

extension TestURL {

    var url: URL {
        guard let url = URL(string: self.urlStr) else {
            fatalError()
        }
        return url
    }

    var urlStr: String {
        switch self {
        case .apple:
            "https://apple.com/"
        case .google:
            "https://google.com/"
        case .plinky:
            "https://www.plinky.app"
        case .w3Schools:
            "https://www.w3schools.com/"
        case .realFaviconGenerator:
            "https://realfavicongenerator.net/blog/apple-touch-icon-the-good-the-bad-the-ugly/"
        case .webApplicationManifest:
            "https://googlechrome.github.io/samples/web-application-manifest/"
        case .metaRefreshRedirect:
            "https://www.sympy.org/"
        case .nonUtf8Encoded:
            "http://foodmate.net/"
        }
    }

}
