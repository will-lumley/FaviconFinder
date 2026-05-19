//
//  FaviconFinderTests.swift
//  FaviconFinderTests
//
//  Created by William Lumley on 16/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

import FaviconFinder
import Foundation
import Testing

struct URLParsingTests {

    // MARK: - urlWithoutSubdomains — simple TLDs

    @Test("Strips subdomain from .com URL")
    func urlWithoutSubdomainsCom() {
        let actual = URL(string: "https://mail.google.com")!.urlWithoutSubdomains
        let expected = URL(string: "https://google.com")
        #expect(actual == expected)
    }

    @Test("Strips subdomain from .net URL")
    func urlWithoutSubdomainsNet() {
        let actual = URL(string: "https://sub.example.net")!.urlWithoutSubdomains
        let expected = URL(string: "https://example.net")
        #expect(actual == expected)
    }

    @Test("Strips subdomain from .org URL")
    func urlWithoutSubdomainsOrg() {
        let actual = URL(string: "https://sub.example.org")!.urlWithoutSubdomains
        let expected = URL(string: "https://example.org")
        #expect(actual == expected)
    }

    @Test("Strips subdomain from .io URL")
    func urlWithoutSubdomainsIO() {
        let actual = URL(string: "https://sub.example.io")!.urlWithoutSubdomains
        let expected = URL(string: "https://example.io")
        #expect(actual == expected)
    }

    @Test("Strips subdomain from .dev URL")
    func urlWithoutSubdomainsDev() {
        let actual = URL(string: "https://sub.example.dev")!.urlWithoutSubdomains
        let expected = URL(string: "https://example.dev")
        #expect(actual == expected)
    }

    @Test("Strips subdomain from .app URL")
    func urlWithoutSubdomainsApp() {
        let actual = URL(string: "https://sub.example.app")!.urlWithoutSubdomains
        let expected = URL(string: "https://example.app")
        #expect(actual == expected)
    }

    @Test("Strips subdomain from .ai URL")
    func urlWithoutSubdomainsAI() {
        let actual = URL(string: "https://sub.example.ai")!.urlWithoutSubdomains
        let expected = URL(string: "https://example.ai")
        #expect(actual == expected)
    }

    @Test("Strips subdomain from .co URL")
    func urlWithoutSubdomainsCo() {
        let actual = URL(string: "https://sub.example.co")!.urlWithoutSubdomains
        let expected = URL(string: "https://example.co")
        #expect(actual == expected)
    }

    @Test("Strips subdomain from .de URL")
    func urlWithoutSubdomainsDe() {
        let actual = URL(string: "https://sub.example.de")!.urlWithoutSubdomains
        let expected = URL(string: "https://example.de")
        #expect(actual == expected)
    }

    @Test("Strips subdomain from .fr URL")
    func urlWithoutSubdomainsFr() {
        let actual = URL(string: "https://sub.example.fr")!.urlWithoutSubdomains
        let expected = URL(string: "https://example.fr")
        #expect(actual == expected)
    }

    @Test("Strips subdomain from .uk URL")
    func urlWithoutSubdomainsUk() {
        let actual = URL(string: "https://sub.example.uk")!.urlWithoutSubdomains
        let expected = URL(string: "https://example.uk")
        #expect(actual == expected)
    }

    @Test("Strips subdomain from .jp URL")
    func urlWithoutSubdomainsJp() {
        let actual = URL(string: "https://sub.example.jp")!.urlWithoutSubdomains
        let expected = URL(string: "https://example.jp")
        #expect(actual == expected)
    }

    // MARK: - urlWithoutSubdomains — compound TLDs

    @Test("Strips subdomain from .co.uk URL")
    func urlWithoutSubdomainsCoUk() {
        let actual = URL(string: "https://mail.google.co.uk")!.urlWithoutSubdomains
        let expected = URL(string: "https://google.co.uk")
        #expect(actual == expected)
    }

    @Test("Strips subdomain from .com.au URL")
    func urlWithoutSubdomainsComAu() {
        let actual = URL(string: "https://sub.apple.com.au")!.urlWithoutSubdomains
        let expected = URL(string: "https://apple.com.au")
        #expect(actual == expected)
    }

    @Test("Strips subdomain from .co.nz URL")
    func urlWithoutSubdomainsCoNz() {
        let actual = URL(string: "https://sub.example.co.nz")!.urlWithoutSubdomains
        let expected = URL(string: "https://example.co.nz")
        #expect(actual == expected)
    }

    @Test("Strips subdomain from .co.jp URL")
    func urlWithoutSubdomainsCoJp() {
        let actual = URL(string: "https://sub.example.co.jp")!.urlWithoutSubdomains
        let expected = URL(string: "https://example.co.jp")
        #expect(actual == expected)
    }

    @Test("Strips subdomain from .co.za URL")
    func urlWithoutSubdomainsCoZa() {
        let actual = URL(string: "https://sub.example.co.za")!.urlWithoutSubdomains
        let expected = URL(string: "https://example.co.za")
        #expect(actual == expected)
    }

    @Test("Strips subdomain from .com.br URL")
    func urlWithoutSubdomainsComBr() {
        let actual = URL(string: "https://sub.example.com.br")!.urlWithoutSubdomains
        let expected = URL(string: "https://example.com.br")
        #expect(actual == expected)
    }

    @Test("Strips subdomain from .net.au URL")
    func urlWithoutSubdomainsNetAu() {
        let actual = URL(string: "https://sub.example.net.au")!.urlWithoutSubdomains
        let expected = URL(string: "https://example.net.au")
        #expect(actual == expected)
    }

    @Test("Strips subdomain from .org.uk URL")
    func urlWithoutSubdomainsOrgUk() {
        let actual = URL(string: "https://sub.example.org.uk")!.urlWithoutSubdomains
        let expected = URL(string: "https://example.org.uk")
        #expect(actual == expected)
    }

    @Test("Strips subdomain from .gov.au URL")
    func urlWithoutSubdomainsGovAu() {
        let actual = URL(string: "https://sub.example.gov.au")!.urlWithoutSubdomains
        let expected = URL(string: "https://example.gov.au")
        #expect(actual == expected)
    }

    @Test("Strips subdomain from .ac.uk URL")
    func urlWithoutSubdomainsAcUk() {
        let actual = URL(string: "https://sub.example.ac.uk")!.urlWithoutSubdomains
        let expected = URL(string: "https://example.ac.uk")
        #expect(actual == expected)
    }

    // MARK: - urlWithoutSubdomains — already at root

    @Test("Root .com domain is unchanged")
    func urlWithoutSubdomainsAlreadyRootCom() {
        let actual = URL(string: "https://google.com")!.urlWithoutSubdomains
        let expected = URL(string: "https://google.com")
        #expect(actual == expected)
    }

    @Test("Root .io domain is unchanged")
    func urlWithoutSubdomainsAlreadyRootIO() {
        let actual = URL(string: "https://example.io")!.urlWithoutSubdomains
        let expected = URL(string: "https://example.io")
        #expect(actual == expected)
    }

    @Test("Root .co.uk domain is unchanged")
    func urlWithoutSubdomainsAlreadyRootCoUk() {
        let actual = URL(string: "https://example.co.uk")!.urlWithoutSubdomains
        let expected = URL(string: "https://example.co.uk")
        #expect(actual == expected)
    }

    @Test("Root .com.au domain is unchanged")
    func urlWithoutSubdomainsAlreadyRootComAu() {
        let actual = URL(string: "https://example.com.au")!.urlWithoutSubdomains
        let expected = URL(string: "https://example.com.au")
        #expect(actual == expected)
    }

    // MARK: - urlWithoutSubdomains — multiple subdomains

    @Test("Strips two levels of subdomains from .com URL")
    func urlWithoutSubdomainsDeepCom() {
        let actual = URL(string: "https://a.b.google.com")!.urlWithoutSubdomains
        let expected = URL(string: "https://google.com")
        #expect(actual == expected)
    }

    @Test("Strips two levels of subdomains from compound TLD URL")
    func urlWithoutSubdomainsDeepCompound() {
        let actual = URL(string: "https://a.b.google.co.uk")!.urlWithoutSubdomains
        let expected = URL(string: "https://google.co.uk")
        #expect(actual == expected)
    }

    // MARK: - urlWithoutSubdomains — paths are stripped

    @Test("Strips path when removing subdomains from .com URL")
    func urlWithoutSubdomainsPathCom() {
        let actual = URL(string: "https://mail.google.com/inbox/123")!.urlWithoutSubdomains
        let expected = URL(string: "https://google.com")
        #expect(actual == expected)
    }

    @Test("Strips path when removing subdomains from compound TLD URL")
    func urlWithoutSubdomainsPathCompound() {
        let actual = URL(string: "https://sub.apple.com.au/path/to/page")!.urlWithoutSubdomains
        let expected = URL(string: "https://apple.com.au")
        #expect(actual == expected)
    }

    // MARK: - urlWithoutSubdomains — scheme preservation

    @Test("Preserves http scheme when stripping subdomains")
    func urlWithoutSubdomainsPreservesHttp() {
        let actual = URL(string: "http://mail.google.com")!.urlWithoutSubdomains
        let expected = URL(string: "http://google.com")
        #expect(actual == expected)
    }

    @Test("Preserves https scheme when stripping subdomains")
    func urlWithoutSubdomainsPreservesHttps() {
        let actual = URL(string: "https://mail.google.com")!.urlWithoutSubdomains
        let expected = URL(string: "https://google.com")
        #expect(actual == expected)
    }

    // MARK: - urlWithoutSubdomains — nil cases

    @Test("Single-label host returns nil")
    func urlWithoutSubdomainsSingleLabel() {
        let actual = URL(string: "https://localhost")!.urlWithoutSubdomains
        #expect(actual == nil)
    }

    @Test("Bare compound TLD with no root returns nil")
    func urlWithoutSubdomainsBareCompoundTLD() {
        let actual = URL(string: "https://co.uk")!.urlWithoutSubdomains
        #expect(actual == nil)
    }

    @Test("Bare country-code TLD with no root returns nil")
    func urlWithoutSubdomainsBareComAu() {
        let actual = URL(string: "https://com.au")!.urlWithoutSubdomains
        #expect(actual == nil)
    }

    // MARK: - absoluteStringWithoutScheme

    @Test("Strips https scheme from URL with path")
    func absoluteStringWithoutSchemeHttps() {
        let actual = URL(string: "https://example.com/path")!.absoluteStringWithoutScheme
        let expected = "example.com/path"
        #expect(actual == expected)
    }

    @Test("Strips http scheme from URL with path")
    func absoluteStringWithoutSchemeHttp() {
        let actual = URL(string: "http://example.com/path")!.absoluteStringWithoutScheme
        let expected = "example.com/path"
        #expect(actual == expected)
    }

    @Test("Strips https scheme from URL without path")
    func absoluteStringWithoutSchemeNoPath() {
        let actual = URL(string: "https://example.com")!.absoluteStringWithoutScheme
        let expected = "example.com"
        #expect(actual == expected)
    }

    @Test("Strips scheme from URL with query string")
    func absoluteStringWithoutSchemeQuery() {
        let actual = URL(string: "https://example.com/path?foo=bar")!.absoluteStringWithoutScheme
        let expected = "example.com/path?foo=bar"
        #expect(actual == expected)
    }

}
