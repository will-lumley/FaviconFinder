//
//  ViewController.swift
//  FaviconFinder_iOS_Example
//
//  Created by Will Lumley on 10/2/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import FaviconFinder

class ViewController: UIViewController
{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    @IBAction func buttonTapped(_ sender: Any)
    {
        guard let urlStr = self.textField.text else {
            print("TextField text is nil.")
            return
        }
        
        guard let url = URL(string: urlStr) else {
            print("Not a valid URL: \(urlStr)")
            return
        }
        
        FaviconFinder(url: url).downloadFavicon({(image, url, error) in
            self.imageView.image = image

            if let error = error {
                print("Error: \(error)")
            }
        })
    }
}

