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

        let nsString = rawName as NSString
        let cfString = nsString as CFString

        let cfName = CFStringConvertIANACharSetNameToEncoding(cfString)
        let constant = CFStringConvertEncodingToNSStringEncoding(cfName)

        let encoded = String.Encoding(rawValue: constant)
        return encoded
    }

}
