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
        #expect(URL(string: "https://mail.google.com")!.urlWithoutSubdomains == URL(string: "https://google.com"))
    }

    @Test("Strips subdomain from .net URL")
    func urlWithoutSubdomainsNet() {
        #expect(URL(string: "https://sub.example.net")!.urlWithoutSubdomains == URL(string: "https://example.net"))
    }

    @Test("Strips subdomain from .org URL")
    func urlWithoutSubdomainsOrg() {
        #expect(URL(string: "https://sub.example.org")!.urlWithoutSubdomains == URL(string: "https://example.org"))
    }

    @Test("Strips subdomain from .io URL")
    func urlWithoutSubdomainsIO() {
        #expect(URL(string: "https://sub.example.io")!.urlWithoutSubdomains == URL(string: "https://example.io"))
    }

    @Test("Strips subdomain from .dev URL")
    func urlWithoutSubdomainsDev() {
        #expect(URL(string: "https://sub.example.dev")!.urlWithoutSubdomains == URL(string: "https://example.dev"))
    }

    @Test("Strips subdomain from .app URL")
    func urlWithoutSubdomainsApp() {
        #expect(URL(string: "https://sub.example.app")!.urlWithoutSubdomains == URL(string: "https://example.app"))
    }

    @Test("Strips subdomain from .ai URL")
    func urlWithoutSubdomainsAI() {
        #expect(URL(string: "https://sub.example.ai")!.urlWithoutSubdomains == URL(string: "https://example.ai"))
    }

    @Test("Strips subdomain from .co URL")
    func urlWithoutSubdomainsCo() {
        #expect(URL(string: "https://sub.example.co")!.urlWithoutSubdomains == URL(string: "https://example.co"))
    }

    @Test("Strips subdomain from .de URL")
    func urlWithoutSubdomainsDe() {
        #expect(URL(string: "https://sub.example.de")!.urlWithoutSubdomains == URL(string: "https://example.de"))
    }

    @Test("Strips subdomain from .fr URL")
    func urlWithoutSubdomainsFr() {
        #expect(URL(string: "https://sub.example.fr")!.urlWithoutSubdomains == URL(string: "https://example.fr"))
    }

    @Test("Strips subdomain from .uk URL")
    func urlWithoutSubdomainsUk() {
        #expect(URL(string: "https://sub.example.uk")!.urlWithoutSubdomains == URL(string: "https://example.uk"))
    }

    @Test("Strips subdomain from .jp URL")
    func urlWithoutSubdomainsJp() {
        #expect(URL(string: "https://sub.example.jp")!.urlWithoutSubdomains == URL(string: "https://example.jp"))
    }

    // MARK: - urlWithoutSubdomains — compound TLDs

    @Test("Strips subdomain from .co.uk URL")
    func urlWithoutSubdomainsCoUk() {
        #expect(URL(string: "https://mail.google.co.uk")!.urlWithoutSubdomains == URL(string: "https://google.co.uk"))
    }

    @Test("Strips subdomain from .com.au URL")
    func urlWithoutSubdomainsComAu() {
        #expect(URL(string: "https://sub.apple.com.au")!.urlWithoutSubdomains == URL(string: "https://apple.com.au"))
    }

    @Test("Strips subdomain from .co.nz URL")
    func urlWithoutSubdomainsCoNz() {
        #expect(URL(string: "https://sub.example.co.nz")!.urlWithoutSubdomains == URL(string: "https://example.co.nz"))
    }

    @Test("Strips subdomain from .co.jp URL")
    func urlWithoutSubdomainsCoJp() {
        #expect(URL(string: "https://sub.example.co.jp")!.urlWithoutSubdomains == URL(string: "https://example.co.jp"))
    }

    @Test("Strips subdomain from .co.za URL")
    func urlWithoutSubdomainsCoZa() {
        #expect(URL(string: "https://sub.example.co.za")!.urlWithoutSubdomains == URL(string: "https://example.co.za"))
    }

    @Test("Strips subdomain from .com.br URL")
    func urlWithoutSubdomainsComBr() {
        #expect(URL(string: "https://sub.example.com.br")!.urlWithoutSubdomains == URL(string: "https://example.com.br"))
    }

    @Test("Strips subdomain from .net.au URL")
    func urlWithoutSubdomainsNetAu() {
        #expect(URL(string: "https://sub.example.net.au")!.urlWithoutSubdomains == URL(string: "https://example.net.au"))
    }

    @Test("Strips subdomain from .org.uk URL")
    func urlWithoutSubdomainsOrgUk() {
        #expect(URL(string: "https://sub.example.org.uk")!.urlWithoutSubdomains == URL(string: "https://example.org.uk"))
    }

    @Test("Strips subdomain from .gov.au URL")
    func urlWithoutSubdomainsGovAu() {
        #expect(URL(string: "https://sub.example.gov.au")!.urlWithoutSubdomains == URL(string: "https://example.gov.au"))
    }

    @Test("Strips subdomain from .ac.uk URL")
    func urlWithoutSubdomainsAcUk() {
        #expect(URL(string: "https://sub.example.ac.uk")!.urlWithoutSubdomains == URL(string: "https://example.ac.uk"))
    }

    // MARK: - urlWithoutSubdomains — already at root

    @Test("Root .com domain is unchanged")
    func urlWithoutSubdomainsAlreadyRootCom() {
        let url = URL(string: "https://google.com")!
        #expect(url.urlWithoutSubdomains == url)
    }

    @Test("Root .io domain is unchanged")
    func urlWithoutSubdomainsAlreadyRootIO() {
        let url = URL(string: "https://example.io")!
        #expect(url.urlWithoutSubdomains == url)
    }

    @Test("Root .co.uk domain is unchanged")
    func urlWithoutSubdomainsAlreadyRootCoUk() {
        let url = URL(string: "https://example.co.uk")!
        #expect(url.urlWithoutSubdomains == url)
    }

    @Test("Root .com.au domain is unchanged")
    func urlWithoutSubdomainsAlreadyRootComAu() {
        let url = URL(string: "https://example.com.au")!
        #expect(url.urlWithoutSubdomains == url)
    }

    // MARK: - urlWithoutSubdomains — multiple subdomains

    @Test("Strips two levels of subdomains from .com URL")
    func urlWithoutSubdomainsDeepCom() {
        #expect(URL(string: "https://a.b.google.com")!.urlWithoutSubdomains == URL(string: "https://google.com"))
    }

    @Test("Strips two levels of subdomains from compound TLD URL")
    func urlWithoutSubdomainsDeepCompound() {
        #expect(URL(string: "https://a.b.google.co.uk")!.urlWithoutSubdomains == URL(string: "https://google.co.uk"))
    }

    // MARK: - urlWithoutSubdomains — paths are stripped

    @Test("Strips path when removing subdomains from .com URL")
    func urlWithoutSubdomainsPathCom() {
        #expect(URL(string: "https://mail.google.com/inbox/123")!.urlWithoutSubdomains == URL(string: "https://google.com"))
    }

    @Test("Strips path when removing subdomains from compound TLD URL")
    func urlWithoutSubdomainsPathCompound() {
        #expect(URL(string: "https://sub.apple.com.au/path/to/page")!.urlWithoutSubdomains == URL(string: "https://apple.com.au"))
    }

    // MARK: - urlWithoutSubdomains — scheme preservation

    @Test("Preserves http scheme when stripping subdomains")
    func urlWithoutSubdomainsPreservesHttp() {
        #expect(URL(string: "http://mail.google.com")!.urlWithoutSubdomains == URL(string: "http://google.com"))
    }

    @Test("Preserves https scheme when stripping subdomains")
    func urlWithoutSubdomainsPreservesHttps() {
        #expect(URL(string: "https://mail.google.com")!.urlWithoutSubdomains == URL(string: "https://google.com"))
    }

    // MARK: - urlWithoutSubdomains — nil cases

    @Test("Single-label host returns nil")
    func urlWithoutSubdomainsSingleLabel() {
        #expect(URL(string: "https://localhost")!.urlWithoutSubdomains == nil)
    }

    @Test("Bare compound TLD with no root returns nil")
    func urlWithoutSubdomainsBareCompoundTLD() {
        // co.uk is itself a TLD, not a registrable domain — no root component exists
        #expect(URL(string: "https://co.uk")!.urlWithoutSubdomains == nil)
    }

    @Test("Bare country-code TLD with no root returns nil")
    func urlWithoutSubdomainsBareComAu() {
        #expect(URL(string: "https://com.au")!.urlWithoutSubdomains == nil)
    }

    // MARK: - absoluteStringWithoutScheme

    @Test("Strips https scheme from URL with path")
    func absoluteStringWithoutSchemeHttps() {
        #expect(URL(string: "https://example.com/path")!.absoluteStringWithoutScheme == "example.com/path")
    }

    @Test("Strips http scheme from URL with path")
    func absoluteStringWithoutSchemeHttp() {
        #expect(URL(string: "http://example.com/path")!.absoluteStringWithoutScheme == "example.com/path")
    }

    @Test("Strips https scheme from URL without path")
    func absoluteStringWithoutSchemeNoPath() {
        #expect(URL(string: "https://example.com")!.absoluteStringWithoutScheme == "example.com")
    }

    @Test("Strips scheme from URL with query string")
    func absoluteStringWithoutSchemeQuery() {
        #expect(URL(string: "https://example.com/path?foo=bar")!.absoluteStringWithoutScheme == "example.com/path?foo=bar")
    }

}
