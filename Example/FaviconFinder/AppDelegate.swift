//
//  AppDelegate.swift
//  FaviconFinderExample
//
//  Created by William Lumley on 18/10/19.
//  Copyright © 2019 William Lumley. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{
    var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        self.window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        self.window.center()
        self.window.contentViewController = ExampleViewController(nibName: "ExampleViewController", bundle: Bundle.main)
        self.window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification)
    {
        
    }
}
