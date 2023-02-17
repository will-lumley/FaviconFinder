#
#  Be sure to run `pod spec lint FaviconFinder.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "FaviconFinder"
  s.version      = "4.1.0"
  s.summary      = "A pure Swift library to detect favicons use by a website."
  s.homepage     = "https://github.com/will-lumley/FaviconFinder.git"
  s.license      = { :type => 'MIT', :file => 'LICENSE.txt' }
  
  s.description      = <<-DESC
    FaviconFinder is a tiny pure Swift library designed for iOS and macOS applications that allows
    you to detect favicons used by a website.
                          DESC

  s.author             = { "William Lumley" => "will@lumley.io" }
  s.social_media_url   = "https://twitter.com/wlumley95"

  s.ios.deployment_target = "15.0"
  s.osx.deployment_target = "12.0"
  
  s.swift_version         = '5.0'
  
  s.source       = { :git => "https://github.com/will-lumley/FaviconFinder.git", :tag => s.version.to_s }
  
  s.source_files = 'Sources/**/*/*'
  
  s.dependency 'SwiftSoup', '~> 2.3.7'
  
end
