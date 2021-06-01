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

        FaviconFinder(url: url, preferredType: .html, preferences: [
            .html: FaviconType.appleTouchIcon.rawValue,
            .ico: "favicon.ico"
        ]).downloadFavicon { result in
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
    }
}

