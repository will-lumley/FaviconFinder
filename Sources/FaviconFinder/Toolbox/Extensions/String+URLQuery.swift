//
//  String+URLQuery.swift
//  FaviconFinder
//
//  Created by William Lumley on 25/9/2024.
//

import Foundation

/// An extension to `String` that provides a method to extract the value of a specific query parameter from a URL string.
///
extension String {

    /// Extracts the value of a query parameter by its name from a URL string.
    ///
    /// If the URL contains the specified query parameter, the method returns its value.
    /// Otherwise, it returns `nil`.
    ///
    /// - Parameter name: The name of the query parameter.
    /// - Returns: The value of the query parameter, or `nil` if the parameter is not found or the URL is invalid.
    ///
    /// - Example:
    ///   ```swift
    ///   let url = "https://example.com/page?query=test&lang=en"
    ///   let queryValue = url.valueOfQueryParam("query")
    ///   // queryValue is "test"
    ///
    ///   let langValue = url.valueOfQueryParam("lang")
    ///   // langValue is "en"
    ///
    ///   let missingValue = url.valueOfQueryParam("missing")
    ///   // missingValue is nil
    ///   ```
    ///   
    func valueOfQueryParam(_ name: String) -> String? {
        guard let url = URL(string: self),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return nil
        }
        return queryItems.first(where: { $0.name == name })?.value
    }

}
