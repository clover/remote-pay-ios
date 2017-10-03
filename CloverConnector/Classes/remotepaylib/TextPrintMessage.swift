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
    public var printRequestId: String?
    public var printer: CLVModels.Printer.Printer?
    
    public init() {
        super.init(method: .PRINT_TEXT)
    }
    
    public required init?(map:Map) {
        super.init(method: .PRINT_TEXT)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        textLines <- map["textLines"]
        printRequestId <- map["externalPrintJobId"]
        printer <- (map["printer"], Message.printerTransform)
    }
}
