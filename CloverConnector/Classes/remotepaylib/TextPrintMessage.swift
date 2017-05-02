//
//  TextPrintMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation

import ObjectMapper


public class TextPrintMessage : Message {
    
    public var textLines:[String]?
    
    public init() {
        super.init(method: .PRINT_TEXT)
    }
    
    public required init?(_ map:Map) {
        super.init(method: .PRINT_TEXT)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map)
        textLines <- map["textLines"]
    }
}
