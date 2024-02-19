![FaviconFinder: Simple Favicon Finding](https://raw.githubusercontent.com/will-lumley/FaviconFinder/main/FaviconFinder.png)

# FaviconFinder
<p align="center">
  <img src="https://github.com/will-lumley/FaviconFinder/actions/workflows/BuildTests-iOS.yml/badge.svg?branch=main" alt="iOS - CI Status">
  <img src="https://github.com/will-lumley/FaviconFinder/actions/workflows/BuildTests-linux.yml/badge.svg?branch=main" alt="macOS - CI Status">
  <img src="https://github.com/will-lumley/FaviconFinder/actions/workflows/BuildTests-macOS.yml/badge.svg?branch=main" alt="Linux - CI Status">
</p>
<p align="center">
  <a href="https://github.com/apple/swift-package-manager"><img src="https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat" alt="SPM Compatible"></a>
  <img src="https://img.shields.io/badge/Swift-5.5-orange.svg" alt="Swift 5.5">
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

To do:
- [ ] Detect and parse web application Microsoft browser configuration XML.

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
image type to cast the data to. Also dueo to this, `largest()` and `smallest()` aren't effective on Linux.


## Advanced Usage & Configuration

### Preferential Downloading

However if you're the type to want to have some fine-tuned control over what sort of favicon's we're after, you can do so.

FaviconFinder allows you to specify which download type you'd prefer (HTML, actual file, or web application manifest file), and then allows you to specify which favicon type you'd prefer for each download type.

For example, you can specify that you'd prefer a HTML tag favicon, with the type of `appleTouchIcon`. FaviconFinder will then search through the HTML favicon tags for the `appleTouchIcon` type. If it cannot find the `appleTouchIcon` type, it will search for the other HTML favicon tag types.   

If the URL does not have a HTML tag that specifies the favicon, FaviconFinder will default to other download types, and will search the URL for each favicon download type until it finds one, or it'll return an error. 

Just like how you can specify which HTML favicon tag you'd prefer, you can set which filename you'd prefer when search for actual files. 

Similarly, you can specify which JSON key you'd prefer when iterating through the web application manifest file. 

For the `.ico` download type, you can request FaviconFinder searchs for a filename of your choosing.

In addition, you can also let FaviconFinder know that you'd like the HTML of the website parsed and analysed for a meta-refresh-redirect tag, and query the new URL if found.

Here's how you'd make that request:

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
- What type of download type FaviconFinder will use first
- When iterating through each download type, what sub-type to look for. For the HTML download type, this allows you to prioritise different "rel" types. For the file.ico type, this allows you to choose the filename.

If your desired download type doesn't exist for your URL (ie. you requested the favicon that exists as a file but there's no file), FaviconFinder will automatically try all other methods of favicon storage for you.

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

## Example Projects

To run the example project, clone the repo, and open the example Xcode Project in either the `iOSFaviconFinderExample`, or `macOSFaviconFinderExample`, depending on your build target.

Alternatively, if you're using this for a Linux project, you can open the example Swift Project located in `LinuxFaviconFinderExample`.

## Requirements

FaviconFinder now supports await/async concurrency, as seen in the examples below. Due to this, the most up to date version of FaviconFinder requires iOS 15.0 and macOS 12.0.
If you need to support older versions of iOS or macOS, version 3.3.0 of FaviconFinder uses closures to call back the success/failure instead of await/async concurrency.

## Installation

### Swift Package Manager
FaviconFinder is also available through [Swift Package Manager](https://github.com/apple/swift-package-manager). 
To install it, simply add the dependency to your Package.Swift file:

```swift
...
dependencies: [
    .package(url: "https://github.com/will-lumley/FaviconFinder.git", from: "5.0.0"),
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
