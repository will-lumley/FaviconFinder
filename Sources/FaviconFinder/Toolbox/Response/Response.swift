import Foundation

#if os(Linux)
typealias Response = LinuxResponse
#else
typealias Response = AppleResponse
#endif