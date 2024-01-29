![FaviconFinder: Simple Favicon Finding](https://raw.githubusercontent.com/will-lumley/FaviconFinder/main/FaviconFinder.png)

# FaviconFinder
![iOS - CI Status](https://github.com/will-lumley/FaviconFinder/actions/workflows/BuildTests-iOS.yml/badge.svg?branch=tech/multiplatform-tests)
![macOS - CI Status](https://github.com/will-lumley/FaviconFinder/actions/workflows/BuildTests-linux.yml/badge.svg?branch=tech/multiplatform-tests)
![Linux - CI Status](https://github.com/will-lumley/FaviconFinder/actions/workflows/BuildTests-macOS.yml/badge.svg?branch=tech/multiplatform-tests)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://github.com/apple/swift-package-manager)
![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg)
[![License](https://img.shields.io/cocoapods/l/FaviconFinder.svg?style=flat)](https://cocoapods.org/pods/FaviconFinder)
[![Twitter](https://img.shields.io/badge/twitter-@wlumley95-blue.svg?style=flat)](https://twitter.com/wlumley95)

FaviconFinder is a small, pure Swift library designed for iOS, macOS and Linux applications that allows you to detect favicons used by a website.

Why not just download the file that exists at `https://site.com/favicon.ico`? There are multiple places that a developer can place their favicon, not just at the root directory with the specific filename of `favicon.ico`. The favicon's address may be linked within the HTML header tags, or it may be within a web application manifest JSON file, or it could even be a file with a custom filename.

FaviconFinder handles the dirty work for you and iterates through the numerous possible favicon locations, and simply delivers the image to you in a closure, once the image is found.


FaviconFinder will:
- [x] Detect the favicon in the root directory of the URL provided.
- [x] Automatically check if the favicon is located within the root URL if the subdomain failed (Will check `https://site.com/favicon.ico` if `https://subdomain.site.com/favicon.ico` fails).
- [x] Detect and parse the HTML at the URL for the declaration of the favicon.
- [x] Resolve the favicon URL for you, even if it's a relative URL to the subdomain that you're querying.
- [x] Allow you to prioritise which format of favicon you would like served.
- [x] Detect and parse web application manifest JSON files for favicon locations.
- [x] If you set `checkForMetaRefreshRedirect` to true, FaviconFinder will analyse the HTML for a meta refresh redirect tag. If such a tag is found, the URL in the tag is the URL that will be queried.

To do:
- [ ] Detect and parse web application Microsoft browser configuration XML.

## Usage

FaviconFinder uses simple syntax to allow you to easily download the favicon you need, and get on with your project. Just insert this code into your project:
```swift
    do {
        let favicon = try await FaviconFinder(url: url).downloadFavicon()

        print("URL of Favicon: \(favicon.url)")
        DispatchQueue.main.async {
            self.imageView.image = favicon.image
        }
    } catch let error {
        print("Error: \(error)")
    }
```

Note that Swift on Linux does not support async/await concurrency. To this point, FaviconFinder has re-implemented it's inner workings using closures for Linux. As these re-implementations are wrapped in an `#if os(Linux)` statement, Linux users can use the same repo as their iOS/macOS counterparts, using the same logic.

Swift on Linux does not natively support image types, so the image is returned in the `data` property of `Favicon`.

Here is an example of using FaviconFinder in Swift on Linux.

```swift
        let faviconFinder = FaviconFinder(url: url)
        faviconFinder.downloadFavicon { result in
            print("Result: \(result)")
        }
```

## Advanced Usage

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
    do {
        let favicon = try await FaviconFinder(
            url: url, 
            preferredType: .html, 
            preferences: [
                .html: FaviconType.appleTouchIcon.rawValue,
                .ico: "favicon.ico",
                .webApplicationManifestFile: FaviconType.launcherIcon4x.rawValue
            ]
        ).downloadFavicon()

        print("URL of Favicon: \(favicon.url)")
        DispatchQueue.main.async {
            self.imageView.image = favicon.image
        }
    } catch let error {
        print("Error: \(error)")
    }
```

This allows you to control:
- What type of download type FaviconFinder will use first
- When iterating through each download type, what sub-type to look for. For the HTML download type, this allows you to prioritise different "rel" types. For the file.ico type, this allows you to choose the filename.

If your desired download type doesn't exist for your URL (ie. you requested the favicon that exists as a file but there's no file), FaviconFinder will automatically try all other methods of favicon storage for you. 

### Fetching without Downloading

If you would like FaviconFinder to fetch the favicon URL without also executing an image download, you can do so with the following parameter:

```swift
    do {
        let favicon = try await FaviconFinder(
            url: url, 
            preferredType: .html, 
            preferences: [
                .html: FaviconType.appleTouchIcon.rawValue,
                .ico: "favicon.ico",
                .webApplicationManifestFile: FaviconType.launcherIcon4x.rawValue
            ],
            downloadImage: false
        ).downloadFavicon()

        print("URL of Favicon: \(favicon.url)")
        DispatchQueue.main.async {
            self.imageView.image = favicon.image
        }
    } catch let error {
        print("Error: \(error)")
    }
```

When the parameter `downloadImage` is set to false, an image download will not occur and only the URL will be returned (wrapped in a Favicon struct).

## Example Project

To run the example project, clone the repo, and run `pod install` from the Example directory first.

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
    .package(url: "https://github.com/will-lumley/FaviconFinder.git", from: "4.3.0"),
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
