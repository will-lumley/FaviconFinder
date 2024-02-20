//
//  URLRequest+StringEncoding.swift
//  Pods
//
//  Created by William Lumley on 8/7/2022.
//

import Foundation

#if os(Linux)
import CoreFoundation
import FoundationNetworking
#endif

extension URLResponse {

    var encoding: String.Encoding {
        guard let rawName = self.textEncodingName else {
            return .utf8
        }

        #if os(Linux)
        return rawName.encoding
        #else
        let cfName = CFStringConvertIANACharSetNameToEncoding(rawName as CFString)

        let constant = CFStringConvertEncodingToNSStringEncoding(cfName)

        let encoded = String.Encoding(rawValue: constant)
        return encoded
        #endif
    }

}

