//
//  FaviconFormatTypeTests.swift
//  FaviconFinder
//

@testable import FaviconFinder
import Testing

struct FaviconFormatTypeTests {

    // MARK: - Raw Values

    @Test("HTML format raw values are correct")
    func htmlRawValues() {
        #expect(FaviconFormatType.appleTouchIcon.rawValue == "apple-touch-icon")
        #expect(FaviconFormatType.appleTouchIconPrecomposed.rawValue == "apple-touch-icon-precomposed")
        #expect(FaviconFormatType.shortcutIcon.rawValue == "shortcut icon")
        #expect(FaviconFormatType.icon.rawValue == "icon")
    }

    @Test("OpenGraph format raw values are correct")
    func openGraphRawValues() {
        #expect(FaviconFormatType.metaThumbnail.rawValue == "thumbnail")
        #expect(FaviconFormatType.metaOpenGraphImage.rawValue == "og:image")
    }

    @Test("ICO format raw value is correct")
    func icoRawValue() {
        #expect(FaviconFormatType.ico.rawValue == "ico")
    }

    @Test("Launcher icon raw values are correct")
    func launcherIconRawValues() {
        #expect(FaviconFormatType.launcherIcon0_75x.rawValue == "launcher-icon-0-75x.png")
        #expect(FaviconFormatType.launcherIcon1x.rawValue == "launcher-icon-1x.png")
        #expect(FaviconFormatType.launcherIcon1_5x.rawValue == "launcher-icon-1-5x.png")
        #expect(FaviconFormatType.launcherIcon2x.rawValue == "launcher-icon-2x.png")
        #expect(FaviconFormatType.launcherIcon3x.rawValue == "launcher-icon-3x.png")
        #expect(FaviconFormatType.launcherIcon4x.rawValue == "launcher-icon-4x.png")
    }

    // MARK: - Init from Raw Value

    @Test("Init from valid raw value succeeds", arguments: [
        ("apple-touch-icon", FaviconFormatType.appleTouchIcon),
        ("icon", FaviconFormatType.icon),
        ("og:image", FaviconFormatType.metaOpenGraphImage),
        ("ico", FaviconFormatType.ico),
        ("launcher-icon-1x.png", FaviconFormatType.launcherIcon1x)
    ])
    func initFromValidRawValue(rawValue: String, expected: FaviconFormatType) {
        #expect(FaviconFormatType(rawValue: rawValue) == expected)
    }

    @Test("Init from invalid raw value returns nil", arguments: [
        "invalid-type",
        "",
        "APPLE-TOUCH-ICON",
        "favicon.ico",
        "manifest"
    ])
    func initFromInvalidRawValue(rawValue: String) {
        #expect(FaviconFormatType(rawValue: rawValue) == nil)
    }

    // MARK: - CaseIterable

    @Test("allCases contains exactly 13 formats")
    func allCasesCount() {
        #expect(FaviconFormatType.allCases.count == 13)
    }

}
