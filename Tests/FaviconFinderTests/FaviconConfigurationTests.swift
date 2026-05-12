//
//  FaviconConfigurationTests.swift
//  FaviconFinder
//

@testable import FaviconFinder
import Testing

struct FaviconConfigurationTests {

    @Test("defaultConfiguration has correct defaults")
    func defaultConfiguration() {
        let config = FaviconFinder.Configuration.defaultConfiguration
        #expect(config.preferredSource == .html)
        #expect(config.preferences.isEmpty)
        #expect(config.checkForMetaRefreshRedirect == false)
        #expect(config.prefetchedHTML == nil)
        #expect(config.httpHeaders == nil)
        #expect(config.acceptHeaderImage == false)
    }

    @Test("Custom preferredSource is stored")
    func customPreferredSource() {
        let config = FaviconFinder.Configuration(preferredSource: .ico)
        #expect(config.preferredSource == .ico)
    }

    @Test("Custom preferences are stored")
    func customPreferences() {
        let config = FaviconFinder.Configuration(preferences: [.ico: "custom.ico", .html: "icon"])
        #expect(config.preferences[.ico] == "custom.ico")
        #expect(config.preferences[.html] == "icon")
    }

    @Test("checkForMetaRefreshRedirect is stored")
    func metaRefreshRedirect() {
        let config = FaviconFinder.Configuration(checkForMetaRefreshRedirect: true)
        #expect(config.checkForMetaRefreshRedirect == true)
    }

    @Test("httpHeaders are stored")
    func httpHeaders() {
        let config = FaviconFinder.Configuration(httpHeaders: ["Authorization": "Bearer token"])
        #expect(config.httpHeaders?["Authorization"] == "Bearer token")
    }

    @Test("acceptHeaderImage is stored")
    func acceptHeaderImage() {
        let config = FaviconFinder.Configuration(acceptHeaderImage: true)
        #expect(config.acceptHeaderImage == true)
    }

}
