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

    init(url: URL, logEnabled: Bool)

    func search(onFind: @escaping ((_ result: Result<URL, FaviconError>) -> Void))

}
