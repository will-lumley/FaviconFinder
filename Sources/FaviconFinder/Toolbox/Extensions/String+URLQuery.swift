//
//  String+URLQuery.swift
//  FaviconFinder
//
//  Created by William Lumley on 25/9/2024.
//

import Foundation

extension String {

    /// Extracts the value of a query parameter by its name from a URL string.
    /// - parameter name: The name of the query parameter.
    /// - returns: The value of the query parameter, or nil if not found.
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
