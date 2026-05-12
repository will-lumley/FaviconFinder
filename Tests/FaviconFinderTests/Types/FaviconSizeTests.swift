//
//  FaviconSizeTests.swift
//  FaviconFinder
//

@testable import FaviconFinder
import Testing

struct FaviconSizeTests {

    @Test("Init with width and height")
    func initWithDoubles() {
        let size = FaviconSize(width: 100, height: 200)
        #expect(size.width == 100)
        #expect(size.height == 200)
    }

    @Test("Init with valid width and height strings")
    func initWithValidStrings() {
        let size = FaviconSize(widthStr: "100", heightStr: "200")
        #expect(size != nil)
        #expect(size?.width == 100)
        #expect(size?.height == 200)
    }

    @Test("Init with valid float strings")
    func initWithFloatStrings() {
        let size = FaviconSize(widthStr: "100.5", heightStr: "200.75")
        #expect(size != nil)
        #expect(size?.width == 100.5)
        #expect(size?.height == 200.75)
    }

    @Test("Init with invalid strings returns nil", arguments: [
        ("abc", "200"),
        ("100", "def"),
        ("abc", "def"),
        ("", "")
    ])
    func initWithInvalidStrings(widthStr: String, heightStr: String) {
        #expect(FaviconSize(widthStr: widthStr, heightStr: heightStr) == nil)
    }

    @Test("Dimension is width multiplied by height")
    func dimension() {
        let size = FaviconSize(width: 100, height: 200)
        #expect(size.dimension == 20_000)
    }

    @Test("Dimension of zero")
    func dimensionZero() {
        #expect(FaviconSize(width: 0, height: 0).dimension == 0)
        #expect(FaviconSize(width: 100, height: 0).dimension == 0)
    }

    @Test("Equatable: equal sizes")
    func equatableEqual() {
        let a = FaviconSize(width: 100, height: 200)
        let b = FaviconSize(width: 100, height: 200)
        #expect(a == b)
    }

    @Test("Equatable: unequal sizes")
    func equatableUnequal() {
        let a = FaviconSize(width: 100, height: 200)
        let b = FaviconSize(width: 50, height: 50)
        #expect(a != b)
    }

}
