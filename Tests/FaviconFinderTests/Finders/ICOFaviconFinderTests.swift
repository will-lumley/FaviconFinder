//
//  ICOFaviconFinderTests.swift
//  FaviconFinder
//

@testable import FaviconFinder
import Foundation
import Testing

struct ICOFaviconFinderTests {

    private let url = URL(string: "https://example.com")!

    @Test("preferredType defaults to favicon.ico")
    func preferredTypeDefault() {
        let finder = ICOFaviconFinder(url: url, configuration: .defaultConfiguration)
        #expect(finder.preferredType == "favicon.ico")
    }

    @Test("preferredType uses configuration preferences")
    func preferredTypeCustom() {
        let config = FaviconFinder.Configuration(preferences: [.ico: "custom-icon.ico"])
        let finder = ICOFaviconFinder(url: url, configuration: config)
        #expect(finder.preferredType == "custom-icon.ico")
    }

}
