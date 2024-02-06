
import FaviconFinder
import Foundation
import FoundationNetworking

@main
struct swift {

    static func main() async {
        let url = URL(string: "https://www.w3schools.com")!

        do {
            let favicon = try await FaviconFinder(url: url).downloadFavicon()
            print("Result: \(favicon)")
        } catch let error {
            print("Error: \(error)")
        }
    }

}
