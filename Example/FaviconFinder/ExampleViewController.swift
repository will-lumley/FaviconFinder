//
//  ExampleViewController.swift
//  FaviconFinder_Example
//
//  Created by William Lumley on 12/1/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Cocoa
import FaviconFinder

class ExampleViewController: NSViewController
{
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var textField: NSTextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        print("ExampleViewController")
    }
    
    @IBAction func downloadButtonTapped(_ sender: Any)
    {
        let urlStr = self.textField.stringValue
        
        guard let url = URL(string: urlStr) else {
            print("Not a valid URL: \(urlStr)")
            return
        }
        
        FaviconFinder(url: url, isLogEnabled: true).downloadFavicon({(image, url, error) in
            print("Favicon URL: \(String(describing: url))")
            
            self.imageView.image = image
            if let error = error {
                NSAlert(error: error).runModal()
            }
        })
    }
}
