//
//  Response.swift
//  FaviconFinder
//
//  Created by William Lumley on 20/2/2024.
//

import Foundation

#if os(Linux)

#endif

struct Response {

    // MARK: - Properties

    let data: Data
    let textEncoding: String.Encoding

    // MARK: - Lifecycle
    
    init(_ rawResponse: (Data, URLResponse)) {
        self.data = rawResponse.0
        self.textEncoding = rawResponse.1.encoding
    }

    #if os(Linux)
    init(data: Data, httpHeaders: HTTPHeaders) {
        self.data = data
        
        let charset = self.responseHeaders["charset"]
        fatalError("Charset: \(charset)")
    }
    #else
    
    #endif

}

// MARK: - String

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
