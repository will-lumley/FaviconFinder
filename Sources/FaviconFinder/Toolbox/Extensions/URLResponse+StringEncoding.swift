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

private extension String {

    /// We need to manually convert our string to String.Encoding
    /// on Linux due to the toll-free bridging from Obj-C to CF classes
    /// is something that's only available on Apple platforms.
    ///
    /// - Returns: The String.Encoding enum that our string represents. Will
    /// return .utf8 is no known equivalent is found.
    var encoding: String.Encoding {
        switch self {
            case "us-ascii":
                return .ascii
            case "x-nextstep", "nextstep":
                return .nextstep
            case "euc-jp":
                return .japaneseEUC
            case "utf-8":
                return .utf8
            case "iso-8859-1", "latin1":
                return .isoLatin1
            case "symbol":
                return .symbol
            case "non-lossy-ascii":
                return .nonLossyASCII
            case "shift_jis", "cp932":
                return .shiftJIS
            case "iso-8859-2", "latin2":
                return .isoLatin2
            case "unicode":
                return .unicode
            case "windows-1251":
                return .windowsCP1251
            case "windows-1252":
                return .windowsCP1252
            case "windows-1253":
                return .windowsCP1253
            case "windows-1254":
                return .windowsCP1254
            case "windows-1250":
                return .windowsCP1250
            case "iso-2022-jp":
                return .iso2022JP
            case "macroman", "x-mac-roman":
                return .macOSRoman
            case "utf-16", "unicodefffe":
                return .utf16
            case "utf-16be":
                return .utf16BigEndian
            case "utf-16le":
                return .utf16LittleEndian
            case "utf-32":
                return .utf32
            case "utf-32be":
                return .utf32BigEndian
            case "utf-32le":
                return .utf32LittleEndian
            default:
                return .utf8
        }
    }
}
