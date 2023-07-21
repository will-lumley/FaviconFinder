//
//  Logger.swift
//  Pods
//
//  Created by William Lumley on 4/3/2022.
//

import Foundation

class Logger {

    var faviconFinder: FaviconFinderProtocol?

    init() {

    }

    init(faviconFinder: FaviconFinderProtocol) {
        self.faviconFinder = faviconFinder
    }

    func print(_ string: String) {
        guard let faviconFinder = self.faviconFinder else {
            return
        }

        if faviconFinder.logEnabled {
            Swift.print("[\(faviconFinder.description)] \(string)")
        }
    }

    static func print(_ actuallyLog: Bool, _ string: String) {
        if actuallyLog {
            Swift.print(string)
        }
    }

}
