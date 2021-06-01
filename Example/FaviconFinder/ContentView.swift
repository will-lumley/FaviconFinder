//
//  ContentView.swift
//  FaviconFinderExample
//
//  Created by William Lumley on 18/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

import SwiftUI
import Combine
import FaviconFinder

@available(OSX 10.15, *)
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

@available(OSX 10.15, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

@available(OSX 10.15, *)
final class ImageLoader: ObservableObject {
    @Published private(set) var image: NSImage? = nil

    private var url: URL? = nil

    func load(url: URL) {
        FaviconFinder(url: url, preferredType: .html, preferences: [
            FaviconDownloadType.html: FaviconType.appleTouchIcon.rawValue,
            FaviconDownloadType.ico: "favicon.ico"
        ]).downloadFavicon { result in
            switch result {
            case .success(let favicon):
                print("URL of Favicon: \(favicon.url)")
                self.image = favicon.image

            case .failure(let error):
                NSAlert(error: error).runModal()
            }
        }
    }
}
