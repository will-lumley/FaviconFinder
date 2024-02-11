//
//  URL+TestData.swift
//
//
//  Created by William Lumley on 11/2/2024.
//

import Foundation

extension URL {

    static var google: URL {
        URL(string: "https://google.com/")!
    }

    static var apple: URL {
        URL(string: "https://apple.com/")!
    }

    static var w3Schools: URL {
        URL(string: "https://www.w3schools.com/")!
    }

    static var realFaviconGenerator: URL {
        URL(string: "https://realfavicongenerator.net/blog/apple-touch-icon-the-good-the-bad-the-ugly/")!
    }

    static var webApplicationManifest: URL {
        URL(string: "https://googlechrome.github.io/samples/web-application-manifest/")!
    }

    static var metaRefreshRedirect: URL {
        URL(string: "https://www.sympy.org/")!
    }

    static var nonUtf8Encoded: URL {
        URL(string: "http://foodmate.net/")!
    }

}
