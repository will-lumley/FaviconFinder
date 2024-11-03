![FaviconFinder: Simple Favicon Finding](https://raw.githubusercontent.com/will-lumley/FaviconFinder/main/FaviconFinder.png)

# FaviconFinder

<p align="center">
  <img src="https://github.com/will-lumley/FaviconFinder/actions/workflows/BuildTests-iOS.yml/badge.svg?branch=main" alt="iOS - CI Status">
  <img src="https://github.com/will-lumley/FaviconFinder/actions/workflows/BuildTests-linux.yml/badge.svg?branch=main" alt="macOS - CI Status">
  <img src="https://github.com/will-lumley/FaviconFinder/actions/workflows/BuildTests-macOS.yml/badge.svg?branch=main" alt="Linux - CI Status">
</p>
<p align="center">
  <a href="https://github.com/apple/swift-package-manager"><img src="https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat" alt="SPM Compatible"></a>
  <img src="https://img.shields.io/badge/Swift-5.10-orange.svg" alt="Swift 5.10">
  <img src="https://img.shields.io/badge/Swift-6.0-orange.svg" alt="Swift 6.0">
  <a href="https://twitter.com/wlumley95">
    <img src="https://img.shields.io/badge/twitter-@wlumley95-blue.svg?style=flat" alt="Twitter">
  </a>
</p>

FaviconFinder is a small, pure Swift library designed for iOS, macOS and Linux applications that allows you to detect favicons used by a website.

Why not just download the file that exists at `https://site.com/favicon.ico`? There are multiple places that a developer can place their favicon, not just at the root directory with the specific filename of `favicon.ico`. The favicon's address may be linked within the HTML header tags, or it may be within a web application manifest JSON file, or it could even be a file with a custom filename.

FaviconFinder handles the dirty work for you and iterates through the numerous possible favicon locations, and simply delivers the image to you once found.

FaviconFinder will:

- [x] Detect the favicon in the root directory of the URL provided.
- [x] Detect and parse the HTML at the URL for the declaration of the favicon.
- [x] Resolve the favicon URL for you, even if it's a relative URL to the subdomain that you're querying.
- [x] Allow you to prioritise which format of favicon you would like served.
- [x] Detect and parse web application manifest JSON files for favicon locations.
- [x] Automatically check if the favicon is located within the root URL if the subdomain failed (Will check `https://site.com/favicon.ico` if `https://subdomain.site.com/favicon.ico` fails).
- [x] If you set `checkForMetaRefreshRedirect` to true, FaviconFinder will analyse the HTML for a meta refresh redirect tag. If such a tag is found, the URL in the tag is the URL that will be queried.
- [x] Sort favicons by size using the sizeTag metadata (either in HTML or the web app manifest) without downloading the images, allowing you to identify the largest or smallest favicon efficiently.
- [x] Support pre-fetched HTML documents, so you can reuse HTML you’ve already downloaded instead of fetching it again.
- [x] Cross-platform support for macOS, macOS Catalyst, iOS, and Linux - and supports SwiftUI, UIKit, and AppKit, ensuring seamless integration across multiple environments and applications.

# Table of Contents

1. [Introduction](#faviconfinder)
2. [Usage](#usage)
3. [How it Works](#how-it-works)
4. [Documentation](#documentation)
5. [Advanced Usage](#advanced-usage--configuration)
   - [Preferential Downloading](#preferential-downloading)
   - [Meta-Refresh Redirects](#meta-refresh-redirects)
   - [Pre-Fetched HTML](#pre-fetched-html)
   - [Querying Favicons Behind Authentication](#querying-favicons-behind-authentication)
   - [Sorting Favicon URLs by Size Without Downloading](#sorting-favicon-urls-by-size-without-downloading)
6. [Example Projects](#example-projects)
7. [Requirements](#requirements)
8. [Installation](#installation)
   - [Swift Package Manager](#swift-package-manager)
   - [Cocoapods and Carthage](#cocoapods-and-carthage)
9. [Author](#author)
10. [License](#license)

## Usage

FaviconFinder uses simple syntax to allow you to easily download the favicon you need, and get on with your project. Just insert this code into your project.

```swift
    let favicon = try await FaviconFinder(url: url)
        .fetchFaviconURLs()
        .download()
        .largest()

    self.imageView.image = favicon.image
```

FaviconFinder will iterate through various sources of where the favicon might live, and will ensure that each source is inspected. Currently, the sources are:

- As a file in the root directory of the URL.
- Declared in the HTML header
- Declared in the Web Application Manifest File

Once FaviconFinder has found all available favicons for a particular source, it will return an array of `FaviconURL`s.
`FaviconURL` will contain the source URL for the image, and other metadata about the image that existed from where it pulled it from (ie. relevant HTML tags and such).

On the array of `FaviconURL`s, you can call `download()` which will download each `FaviconURL` and turn your array into an array of `Favicon`s.
`Favicon` contains the image, its raw data, and the `FaviconURL` property.

On the array of `Favicon`s, you can call:

- `first()` if you don't care about the size of the favicon, you just want whichever
- `largest()` if you want the largest favicon we found
- `smallest()` if you want the smallest favicon we found

FaviconFinder works with UIKit, SwiftUI, AppKit, and macOS Catalyst.

FaviconFinder also supports Linux as a platform, and I have re-implemented parts of FaviconFinder to ensure that Linux is treated as a first-class platform.
It's important to note that Swift on Linux doesn't natively support any `Image` format, so when you call download, the `data` itself is downloaded but there's no
image type to cast the data to. Also due to this, `largest()` and `smallest()` aren't effective on Linux.

## How it Works

FaviconFinder simplifies the process of locating and retrieving favicons by automating the search through the various places where a favicon can be defined. Since favicons can exist in multiple locations, FaviconFinder systematically queries each potential source, following a priority order that you can customise.

**Key Steps**
1. HTML Header Query and Parsing
FaviconFinder begins by querying the URL you provide. It then inspects the HTML of the webpage and looks for any favicon declarations in the `<link>` or `<meta>` tags within the header of the downloaded HTML file. This can include favicons specified as standard icons (`<link rel="icon">`), Apple touch icons (`<link rel="apple-touch-icon">`), or others defined within the Open Graph metadata.

2.	Fallback to the Favicon File
If no favicon is found within the HTML, FaviconFinder checks for the traditional favicon location at the root of the domain (https://site.com/favicon.ico). This is the default location where many sites place their favicons, so this check is a quick and effective fallback. If none is found here, FaviconFinder will check if the URL provided is a subdomain (ie. https://example.site.com), and if it is, will query the root domain (ie. https://site.com).

3.	Fallback to the Web Application Manifest File
For sites that utilise a web application manifest (manifest.json), FaviconFinder parses the JSON file to look for any icons defined specifically for progressive web applications. These are often found in mobile-optimised websites or applications and provide higher-resolution favicons.

4.	Meta-Refresh Redirects (Optional)
Some websites may use meta-refresh redirects instead of server-side HTTP redirects. If enabled in the configuration, FaviconFinder will inspect the HTML for these meta-refresh redirects and follow them to retrieve the favicon from the redirected URL.

5.	Favicon Size Sorting
FaviconFinder extracts size metadata from the HTML or web application manifest to sort favicons by their dimensions (e.g., 120x120, 32x32). This allows you to easily determine the largest or smallest favicon without downloading every image, saving bandwidth and improving performance.

6.	Customisation and Preferences
FaviconFinder allows you to customise how it searches for favicons. You can prioritise certain favicon types (e.g., Apple touch icons, .ico files) and even provide pre-fetched HTML or custom HTTP headers for authentication, giving you full control over how the library interacts with the site.

7.	Cross-Platform Compatibility
FaviconFinder is designed to work across macOS, iOS, and Linux. It adjusts its methods depending on the platform, so you can use it seamlessly whether you’re working in SwiftUI, UIKit, or AppKit. On Linux, FaviconFinder ensures compatibility even though the platform lacks native image handling, using data-driven methods instead.

## Documentation

While this README provides a basic rundown of FaviconFinder, how to use it and what it can do, a much more thorough documentation can be found here:

https://will-lumley.github.io/FaviconFinder/documentation/faviconfinder/

## Advanced Usage & Configuration

### Preferential Downloading

If you want fine-tuned control over the type of favicon you’re looking for, FaviconFinder lets you specify your preferences with ease. You can choose which favicon source you’d prefer to query first—whether it’s HTML, an actual file, or a web application manifest file—and even specify which favicon type you’d like for each source.

For example, you might prefer a favicon declared in the HTML header and specifically want the appleTouchIcon type. FaviconFinder will search the HTML for that specific tag, but if it’s not found, it will automatically search for other HTML favicon types.

If a specified download type (e.g., HTML or .ico) isn’t available, FaviconFinder will automatically try other available methods, and if none are found, it will return an error.

You can also request that FaviconFinder checks for meta-refresh redirects in the HTML, allowing it to follow any redirects and query the correct URL.

Here’s an example of how to configure your preferences:

```swift
    let favicon = try await FaviconFinder(
        url: url,
        configuration: .init(
            preferredSource: .html,
            preferences: [
                .html: FaviconFormatType.appleTouchIcon.rawValue,
                .ico: "favicon.ico",
                .webApplicationManifestFile: FaviconFormatType.launcherIcon4x.rawValue
            ]
        )
    )
        .fetchFaviconURLs()
        .download()
        .largest()

    self.imageView.image = favicon.image
```

This allows you to control:
- The preferred download source type FaviconFinder should use first.
- The specific sub-type to prioritize within each download type (e.g., HTML rel types, filenames for .ico files, or keys in the web application manifest file).

If your preferred download type isn’t available at the URL (e.g., there’s no file or no HTML tag specifying the favicon), FaviconFinder will try other sources until it finds a valid favicon or returns an error.

### Meta-Refresh Redirects

When a site is moved from oldsite.com to newsite.com, it's common practice to have oldsite.com respond with a HTTP 301 Redirect, along with a URL to redirect to.
In this example, `URLSession` (and by extension most libraries that fetch favicons) will natively re-request newsite.com once the HTTP 301 redirect is received.

However there is a lesser-practiced (and frankly inferior) method of redirecting - and it's called the meta-refresh redirect.

This is similar to the HTTP 301 Redirect, except it occurs in the front-end and the browser is expected to read & parse the HTML and send the user to the new URL that way.
When `URLSession` encounters a HTTP request that points to a HTML file that contains a meta-refresh redirect, nothing happens.

However with `FaviconFinder` you're in luck. If you set it to do so within the configuration, `FaviconFinder` will scan the HTML at the URL you provide it for any meta-refresh redirects to make sure that if a
meta-refresh redirect is encountered, you don't have to worry about it.

It's important to note however that parsing and checking for this can take extra compute time, so by default it's set to off.

Here is how you would use it.

```swift
    let favicon = try await FaviconFinder(
        url: url,
        configuration: .init(
            preferredSource: .html,
            preferences: [
                .html: FaviconFormatType.appleTouchIcon.rawValue,
                .ico: "favicon.ico",
                .webApplicationManifestFile: FaviconFormatType.launcherIcon4x.rawValue
            ],
            checkForMetaRefreshRedirect: true
        )
    )
        .fetchFaviconURLs()
        .download()
        .largest()

    self.imageView.image = favicon.image
```

### Pre-Fetched HTML

FaviconFinder allows you to pass a pre-fetched HTML document to avoid downloading the HTML multiple times or if you already have the HTML content available from another source. You can use the prefetchedHTML property in the configuration to pass this document.

We use the Document type of SwiftSoup, as it has amazing HTML storing and parsing capabilities, allowing for easy manipulation and traversal of the document tree.

This feature is useful when:

- You have already downloaded the HTML document elsewhere in your app and want to reuse it.
- You’re working with local HTML files or custom documents.
- You want to optimise performance by reducing the number of HTTP requests.

Here's how you can use it:

```swift
import SwiftSoup

// Assuming you have already fetched and parsed the HTML
let htmlString = "<html><head>...</head></html>"
let document = try SwiftSoup.parse(htmlString)

let favicon = try await FaviconFinder(
    url: url,
    configuration: .init(prefetchedHTML: document)
)
    .fetchFaviconURLs()
    .download()
    .largest()

self.imageView.image = favicon.image
```

### Querying Favicons Behind Authentication

In some cases, favicons might be stored behind an authentication layer or require custom HTTP headers to access, such as API tokens or cookies for user sessions. FaviconFinder supports querying favicons using custom HTTP headers, allowing you to fetch favicons even if they require authentication.

To specify custom HTTP headers, you can pass them in the Configuration object when initializing FaviconFinder. These headers will be sent with every HTTP request FaviconFinder makes, ensuring that the favicon can be accessed even if it’s behind an authentication layer.

Below is an example of how to set up a request using custom HTTP headers to access favicons that require authentication (e.g., using a bearer token):

```swift
let headers = [
    "Authorization": "Bearer your_token_here",
    "Cookie": "session_id=your_session_id_here"
]

let favicon = try await FaviconFinder(
    url: url,
    configuration: .init(
        httpHeaders: headers
    )
)
    .fetchFaviconURLs()
    .download()
    .largest()

self.imageView.image = favicon.image
```

By providing custom HTTP headers, you can handle more advanced scenarios where favicons are restricted or protected behind security layers, ensuring that FaviconFinder remains flexible and functional in a variety of environments.

### Sorting Favicon URLs by Size Without Downloading

FaviconFinder includes functionality that allows you to determine the largest or smallest favicon available without needing to download all the images first. This is useful for optimising performance when you only need the largest or smallest image based on size metadata.

By inspecting the size tags provided in the HTML or web application manifest file, FaviconFinder can sort through the available favicon URLs and select the one with the largest or smallest dimensions.

To find the largest or smallest favicon URL without downloading the images:

```swift
let faviconURL = try await FaviconFinder(url: url)
    .fetchFaviconURLs()
    .largest()  // or .smallest()

print("Largest Favicon URL: \(faviconURL.source)")
```

This will return the largest or smallest favicon based on the metadata in the size tag.

Once you have identified the largest or smallest favicon URL, you can then proceed to download the actual image:

```swift
let largestFavicon = try await FaviconFinder(url: url)
    .fetchFaviconURLs()
    .largest()
    .download()

self.imageView.image = largestFavicon.image
```

There are pros and cons to using this approach.

Advantages

- No need to download all the images to determine which one is largest or smallest.
- Optimises performance by focusing on the favicons that meet your size requirements.

Limitations

- The sizeTag metadata must be accurately set by the source (HTML or web app manifest).
- The actual image size may differ if the source configuration is incorrect.

This functionality allows you to efficiently sort favicon URLs by size and download only the favicons you need, making it a powerful tool for handling favicons in an optimised manner.

### Header & Hero Images

There are times where you would like to fetch the header or hero image from a URL. You can let FaviconFinder know that you want it to do this with the `acceptHeaderImage` parameter in the configuration.
With the default value set to `false`, this parameter is an opt-in one.

You can use it as so:

```swift
let favicon = try await FaviconFinder(
    url: url,
    configuration: .init(acceptHeaderImage: true)
)
    .fetchFaviconURLs()
    .download()
    .largest()
```

## Example Projects

To run the example project, clone the repo, and open the example Xcode Project in either the `iOSFaviconFinderExample`, or `macOSFaviconFinderExample`, depending on your build target.

Alternatively, if you're using this for a Linux project, you can open the example Swift Project located in `LinuxFaviconFinderExample`.

## Requirements

FaviconFinder is now written with Swift 6.0. This means we get to use `Swift Testing` over `XCTest`, but more importantly means FaviconFinder is now data-race safe and adheres to strict concurrency.

Swift 6.0 is supported from version `5.1.0` and up. If you need FaviconFinder in Swift 5.9 and below, please use version `5.0.4`.

FaviconFinder now supports await/async concurrency, as seen in the examples below. Due to this, the most up to date version of FaviconFinder requires iOS 15.0 and macOS 12.0.
If you need to support older versions of iOS or macOS, version `3.3.0` of FaviconFinder uses closures to call back the success/failure instead of await/async concurrency.

## Installation

### Swift Package Manager

FaviconFinder is available through [Swift Package Manager](https://github.com/apple/swift-package-manager).
To install it, simply add the dependency to your Package.Swift file:

```swift
...
dependencies: [
    .package(url: "https://github.com/will-lumley/FaviconFinder.git", from: "5.1.4"),
],
targets: [
    .target( name: "YourTarget", dependencies: ["FaviconFinder"]),
]
...
```

### Cocoapods and Carthage

FaviconFinder was previously available through CocoaPods and Carthage, however making the library available to all three Cocoapods,
Carthage, and SPM (and functional to all three) was becoming troublesome. This, combined with the fact that SPM has seen a serious
up-tick in adoption & functionality, has led me to remove support for CocoaPods and Carthage.

## Author

[William Lumley](https://lumley.io/), will@lumley.io

## License

FaviconFinder is available under the MIT license. See the LICENSE file for more info.
