![FaviconFinder: Simple Favicon Finding](https://raw.githubusercontent.com/will-lumley/FaviconFinder/master/FaviconFinder.png)

# FaviconFinder

[![CI Status](https://img.shields.io/travis/will-lumley/FaviconFinder.svg?style=flat)](https://travis-ci.org/will-lumley/FaviconFinder)
[![Version](https://img.shields.io/cocoapods/v/FaviconFinder.svg?style=flat)](https://cocoapods.org/pods/FaviconFinder)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/FaviconFinder.svg?style=flat)](https://cocoapods.org/pods/FaviconFinder)
![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg)
[![Platform](https://img.shields.io/cocoapods/p/FaviconFinder.svg?style=flat)](https://cocoapods.org/pods/FaviconFinder)
[![Twitter](https://img.shields.io/badge/twitter-@wlumley95-blue.svg?style=flat)](https://twitter.com/wlumley95)

FaviconFinder is a tiny, pure Swift library designed for iOS and macOS applications that allows you to detect favicons used by a website.

Why not just download the file that exists at `https://site.com/fav.ico`? There are multiple places that a developer can place there favicon, not just at the root directory with the specific filename of `fav.ico`. FaviconFinder handles the dirty work for you and iterates through the numerous locations that the favicon could be located at, and simply delivers the image to you in a closure, once the image is found.


Favicon will:
- [x] Detect the favicon in the root directory
- [x] Will automatically check if the favicon is located within the root URL if the subdomain failed (Will check `https://site.com/fav.ico` if `https://subdomain.site.com/fav.ico` fails)
- [x] Detect and parse the HTML at the URL for the declaration of the favicon


To do:
- [ ] Detect and parse web application manifest JSON files
- [ ] Detect and parse web application Microsoft browser configuration XML

## Usage

FaviconFinder uses simple syntax to allow you to easily download the favicon you need, and get on with your project. Just insert this code into your project:
```swift
FaviconFinder(url: url).downloadFavicon { (image, error) in
    // Do whatever you'd like with 'image' here
}
```


## Example Project

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

FaviconFinder supports iOS 10.0 and above & macOS 10.10 and above.

## Installation

### Cocoapods
FaviconFinder is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'FaviconFinder'
```
### Carthage
FaviconFinder is also available through [Carthage](https://github.com/Carthage/Carthage). To install
it, simply add the following line to your Cartfile:

```ruby
github "will-lumley/FaviconFinder"
```

## Author

William Lumley, will@lumley.io

## License

FaviconFinder is available under the MIT license. See the LICENSE file for more info.
