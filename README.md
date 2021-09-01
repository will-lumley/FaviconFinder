![FaviconFinder: Simple Favicon Finding](https://raw.githubusercontent.com/will-lumley/FaviconFinder/main/FaviconFinder.png)

# FaviconFinder

[![CI Status](https://api.travis-ci.com/will-lumley/FaviconFinder.svg?branch=main)](https://travis-ci.com/will-lumley/FaviconFinder)
[![Version](https://img.shields.io/cocoapods/v/FaviconFinder.svg?style=flat)](https://cocoapods.org/pods/FaviconFinder)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://github.com/apple/swift-package-manager)
![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg)
[![Platform](https://img.shields.io/cocoapods/p/FaviconFinder.svg?style=flat)](https://cocoapods.org/pods/FaviconFinder)
[![License](https://img.shields.io/cocoapods/l/FaviconFinder.svg?style=flat)](https://cocoapods.org/pods/FaviconFinder)
[![Twitter](https://img.shields.io/badge/twitter-@wlumley95-blue.svg?style=flat)](https://twitter.com/wlumley95)

FaviconFinder is a small, pure Swift library designed for iOS and macOS applications that allows you to detect favicons used by a website.

Why not just download the file that exists at `https://site.com/favicon.ico`? There are multiple places that a developer can place there favicon, not just at the root directory with the specific filename of `favicon.ico`. The favicons address may be linked within the HTML header tags, or it may be within a web application manifest JSON file, or it could even be a file with a custom filename.

FaviconFinder handles the dirty work for you and iterates through the numerous locations that the favicon could be located at, and simply delivers the image to you in a closure, once the image is found.


FaviconFinder will:
- [x] Detect the favicon in the root directory of the URL provided
- [x] Automatically check if the favicon is located within the root URL if the subdomain failed (Will check `https://site.com/favicon.ico` if `https://subdomain.site.com/favicon.ico` fails)
- [x] Detect and parse the HTML at the URL for the declaration of the favicon
- [x] Resolve the favicon URL for you, even if it's a relative URL to the subdomain that you're querying
- [x] Allow you to prioritise which format of favicon you would like served
- [x] Detect and parse web application manifest JSON files for favicon locations

To do:
- [ ] Detect and parse web application Microsoft browser configuration XML

## Usage

FaviconFinder uses simple syntax to allow you to easily download the favicon you need, and get on with your project. Just insert this code into your project:
```swift
FaviconFinder(url: url).downloadFavicon { result in
    switch result {
    case .success(let favicon):
        print("URL of Favicon: \(favicon.url)")
        DispatchQueue.main.async {
            self.imageView.image = favicon.image
        }

    case .failure(let error):
        print("Error: \(error)")
    }
}
```

## Advanced Usage

However if you're the type to want to have some fine-tuned control over what sort of favicon's we're after, you can do so.

FaviconFinder allows you to specify which download type you'd prefer (HTML, actual file, or web application manifest file), and then allows you to specify which favicon type you'd prefer for each download type.

For example, you can specify that you'd prefer a HTML tag favicon, with the type of `appleTouchIcon`. FaviconFinder will then search through the HTML favicon tags for the `appleTouchIcon` type. If it cannot find the `appleTouchIcon` type, it will search for the other HTML favicon tag types.   

If the URL does not have a HTML tag that specifies the favicon, FaviconFinder will default to other download types, and will search the URL for each favicon download type until it finds one, or it'll return an error. 

Just like how you can specify which HTML favicon tag you'd prefer, you can set which filename you'd prefer when search for actual files. 

Similarly, you can specify which JSON key you'd prefer when iterating through the web application manifest file. 


For the `.ico` download type, you can request FaviconFinder searchs for a filename of your choosing.


Here's how you'd make that request:

```swift
    FaviconFinder(
        url: url, 
        preferredType: .html, 
        preferences: [
            .html: FaviconType.appleTouchIcon.rawValue,
            .ico: "favicon.ico",
            .webApplicationManifestFile: FaviconType.launcherIcon4x.rawValue
        ],
        logEnabled: true
    ).downloadFavicon { result in
        switch result {
        case .success(let favicon):
            print("URL of Favicon: \(favicon.url)")
            DispatchQueue.main.async {
                self.imageView.image = favicon.image
            }

        case .failure(let error):
            print("Error: \(error)")
        }
    }
```

This allows you to control:
- What type of download type FaviconFinder will use first
- When iterating through each download type, what sub-type to look for. For the HTML download type, this allows you to prioritise different "rel" types. For the file.ico type, this allows you to choose the filename.

If your desired download type doesn't exist for your URL (ie. you requested the favicon that exists as a file but there's no file), FaviconFinder will automatically try all other methods of favicon storage for you. 

## Example Project

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

FaviconFinder supports iOS 10.0 and above & macOS 10.10 and above.

## Installation

### Cocoapods
FaviconFinder is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'FaviconFinder', '3.2.0'
```

### Carthage
FaviconFinder is also available through [Carthage](https://github.com/Carthage/Carthage). To install
it, simply add the following line to your Cartfile:

```ruby
github "will-lumley/FaviconFinder" == 3.2.0
```

### Swift Package Manager
FaviconFinder is also available through [Swift Package Manager](https://github.com/apple/swift-package-manager). 
To install it, simply add the dependency to your Package.Swift file:

```swift
...
dependencies: [
    .package(url: "https://github.com/will-lumley/FaviconFinder.git", from: "3.2.0"),
],
targets: [
    .target( name: "YourTarget", dependencies: ["FaviconFinder"]),
]
...
```
## Author

[William Lumley](https://lumley.io/), will@lumley.io

## License

FaviconFinder is available under the MIT license. See the LICENSE file for more info.
