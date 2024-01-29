//
//  ContentView.swift
//  macOSFaviconFinderExample
//
//  Created by William Lumley on 29/1/2024.
//

import FaviconFinder
import SwiftUI

struct ContentView: View {

    @State var urlStr = "https://apple.com/au"
    @ObservedObject var imageLoader = ImageLoader()

    var body: some View {
        VStack {
            Image(nsImage: self.imageLoader.image ?? NSImage())
                .frame(width: 100.0, height: 100.0, alignment: .center)
                .aspectRatio(contentMode: .fit)

            TextField("Enter URL", text: $urlStr)
                .border(Color.black)
                .autocorrectionDisabled()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(25.0)

            Button(action: {
                guard let url = URL(string: self.urlStr) else {
                    print("Not a valid URL: \(self.urlStr)")
                    return
                }

                self.imageLoader.load(url: url)

            }, label: {
                Text("Download Favicon")
            }).padding(50.0)

            Spacer()
        }
    }
}

final class ImageLoader: ObservableObject {
    @Published private(set) var image: NSImage? = nil
    
    private var url: URL? = nil
    
    func load(url: URL) {
        Task {
            do {
                let favicon = try await FaviconFinder(url: url, preferredType: .html, preferences: [
                    FaviconDownloadType.html: FaviconType.appleTouchIcon.rawValue,
                    FaviconDownloadType.ico: "favicon.ico"
                ]).downloadFavicon()

                DispatchQueue.main.async {
                    self.image = favicon.image
                }
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    ContentView()
}
