![FaviconFinder: Simple Favicon Finding](https://raw.githubusercontent.com/will-lumley/FaviconFinder/master/FaviconFinder.png)

# FaviconFinder

[![CI Status](https://img.shields.io/travis/will-lumley/FaviconFinder.svg?style=flat)](https://travis-ci.org/will-lumley/FaviconFinder)
[![Version](https://img.shields.io/cocoapods/v/FaviconFinder.svg?style=flat)](https://cocoapods.org/pods/FaviconFinder)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/FaviconFinder.svg?style=flat)](https://cocoapods.org/pods/FaviconFinder)
[![Platform](https://img.shields.io/cocoapods/p/FaviconFinder.svg?style=flat)](https://cocoapods.org/pods/FaviconFinder)
[![Twitter](https://img.shields.io/badge/twitter-@wlumley95-blue.svg?style=flat)](https://twitter.com/wlumley95)

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

FaviconFinder supports macOS 10.10 and above.

## Installation

FaviconFinder is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'FaviconFinder'
```

## Author

William Lumley, will@lumley.io

## License

FaviconFinder is available under the MIT license. See the LICENSE file for more info.
