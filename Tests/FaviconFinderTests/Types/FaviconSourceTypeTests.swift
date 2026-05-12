//
//  FaviconSourceTypeTests.swift
//  FaviconFinder
//

@testable import FaviconFinder
import Foundation
import Testing

struct FaviconSourceTypeTests {

    private let url = URL(string: "https://example.com")!
    private let config = FaviconFinder.Configuration.defaultConfiguration

    // MARK: - allCases

    @Test("allCases contains html, ico, webApplicationManifestFile")
    func allCasesContent() {
        let cases = FaviconSourceType.allCases
        #expect(cases.contains(.html))
        #expect(cases.contains(.ico))
        #expect(cases.contains(.webApplicationManifestFile))
    }

    @Test("allCases excludes mock")
    func allCasesExcludesMock() {
        #expect(!FaviconSourceType.allCases.contains(.mock))
    }

    @Test("allCases has exactly 3 elements")
    func allCasesCount() {
        #expect(FaviconSourceType.allCases.count == 3)
    }

    // MARK: - init(format:)

    @Test("init(format:) maps ico format to ico source")
    func initFormatIco() {
        #expect(FaviconSourceType(format: .ico) == .ico)
    }

    @Test("init(format:) maps HTML formats to html source", arguments: [
        FaviconFormatType.appleTouchIcon,
        FaviconFormatType.appleTouchIconPrecomposed,
        FaviconFormatType.shortcutIcon,
        FaviconFormatType.icon,
        FaviconFormatType.metaThumbnail,
        FaviconFormatType.metaOpenGraphImage
    ])
    func initFormatHtml(format: FaviconFormatType) {
        #expect(FaviconSourceType(format: format) == .html)
    }

    @Test("init(format:) maps launcher icon formats to webApplicationManifestFile source", arguments: [
        FaviconFormatType.launcherIcon0_75x,
        FaviconFormatType.launcherIcon1x,
        FaviconFormatType.launcherIcon1_5x,
        FaviconFormatType.launcherIcon2x,
        FaviconFormatType.launcherIcon3x,
        FaviconFormatType.launcherIcon4x
    ])
    func initFormatWebAppManifest(format: FaviconFormatType) {
        #expect(FaviconSourceType(format: format) == .webApplicationManifestFile)
    }

    // MARK: - finder(url:configuration:)

    @Test("finder returns HTMLFaviconFinder for .html")
    func finderHtml() {
        let finder = FaviconSourceType.html.finder(url: url, configuration: config)
        #expect(finder is HTMLFaviconFinder)
    }

    @Test("finder returns ICOFaviconFinder for .ico")
    func finderIco() {
        let finder = FaviconSourceType.ico.finder(url: url, configuration: config)
        #expect(finder is ICOFaviconFinder)
    }

    @Test("finder returns WebApplicationManifestFaviconFinder for .webApplicationManifestFile")
    func finderWebAppManifest() {
        let finder = FaviconSourceType.webApplicationManifestFile.finder(url: url, configuration: config)
        #expect(finder is WebApplicationManifestFaviconFinder)
    }

    @Test("finder returns MockFaviconFinder for .mock")
    func finderMock() {
        let finder = FaviconSourceType.mock.finder(url: url, configuration: config)
        #expect(finder is MockFaviconFinder)
    }

}
