//
//  ViewController.swift
//  FaviconFinder_iOS_Example
//
//  Created by Will Lumley on 10/2/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import FaviconFinder

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func buttonTapped(_ sender: Any) {
        guard let urlStr = self.textField.text else {
            print("TextField text is nil.")
            return
        }
        
        guard let url = URL(string: urlStr) else {
            print("Not a valid URL: \(urlStr)")
            return
        }

        Task {
            do {
                let favicon = try await FaviconFinder(url: url, preferredType: .html, preferences: [
                    FaviconDownloadType.html: FaviconType.appleTouchIcon.rawValue,
                    FaviconDownloadType.ico: "favicon.ico"
                ]).downloadFavicon()

                print("URL of Favicon: \(favicon.url)")
                DispatchQueue.main.async {
                    self.imageView.image = favicon.image
                }

            } catch let error {
                print("Error: \(error)")
            }
        }
    }
}

