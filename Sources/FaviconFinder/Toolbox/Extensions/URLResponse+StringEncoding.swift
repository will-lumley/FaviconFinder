//
//  URLRequest+StringEncoding.swift
//  FaviconFinder
//
//  Created by William Lumley on 8/7/2022.
//

import Foundation

#if !os(Linux)

/// An extension to `URLResponse` that provides a utility to extract the string encoding
/// from the response's text encoding name.
///
extension URLResponse {

    /// Determines the string encoding of the response based on the `textEncodingName` property.
    ///
    /// - Returns: A `String.Encoding` value representing the encoding of the response. If no encoding is provided in the response, `.utf8` is returned by default.
    ///
    /// - Example:
    ///   ```swift
    ///   if let response = urlResponse {
    ///       let encoding = response.encoding
    ///       // encoding is the encoding for the response, or UTF-8 if not specified
    ///   }
    ///   ```
    ///   
    var encoding: String.Encoding {
        guard let rawName = self.textEncodingName else {
            return .utf8
        }

        let cfName = CFStringConvertIANACharSetNameToEncoding(rawName as CFString)

        let constant = CFStringConvertEncodingToNSStringEncoding(cfName)

        let encoded = String.Encoding(rawValue: constant)
        return encoded
    }

}

#endif
