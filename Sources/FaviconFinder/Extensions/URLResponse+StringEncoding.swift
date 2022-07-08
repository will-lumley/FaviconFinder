//
//  URLRequest+StringEncoding.swift
//  Pods
//
//  Created by William Lumley on 8/7/2022.
//

import Foundation

extension URLResponse {

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
