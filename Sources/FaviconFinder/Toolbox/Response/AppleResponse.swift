import Foundation

struct AppleResponse {

    // MARK: - Properties

    let data: Data
    let rawResponse: URLResponse

    // MARK: - Lifecycle
    
    init(_ rawResponse: (Data, URLResponse)) {
        self.data = rawResponse.0
        self.rawResponse = rawResponse.1
    }

}

extension AppleResponse {

    var encoding: String.Encoding {
        guard let rawName = rawResponse.textEncodingName else {
            return .utf8
        }

        let cfName = CFStringConvertIANACharSetNameToEncoding(rawName as CFString)
        let constant = CFStringConvertEncodingToNSStringEncoding(cfName)
        let encoded = String.Encoding(rawValue: constant)

        return encoded
    }

}