//
//  XMLParser.swift
//  FaviconFinder
//
//  Created by Will Lumley on 29/1/20.
//

import Foundation

internal class HTMLParser: NSObject
{
    ///The data that would make up the HTML
    internal let data: Data
    
    ///Closure that's thrown on an error occuring
    internal var onError: () -> Void
    
    fileprivate let xmlParser: XMLParser
    
    init(data: Data, onError: @escaping () -> Void)
    {
        self.data      = data
        self.onError   = onError
        
        self.xmlParser = XMLParser(data: data)
        
        super.init()
        
        self.xmlParser.delegate = self
        self.xmlParser.parse()
    }
}

extension HTMLParser: XMLParserDelegate
{
    
}
