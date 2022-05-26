//
//  File.swift
//  Pods
//
//  Created by William Lumley on 26/5/21.
//

import Foundation

protocol FaviconFinderProtocol {

    var url: URL { get set }
    var logEnabled: Bool { get set }
    var preferredType: String { get set }

    init(url: URL, preferredType: String?, logEnabled: Bool)

    func search() async throws -> FaviconURL

}
