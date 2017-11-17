//
//  ImagePrintMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class ImagePrintMessage : Message {
    public var png:[UInt8]?
    public var urlString:String?
    public var printRequestId: String?
    public var printer:CLVModels.Printer.Printer?

    public init() {
        super.init(method: Method.PRINT_IMAGE)
    }
    
    public required init?(map:Map) {
        super.init(method: Method.PRINT_IMAGE)
    }

    public override func mapping(map:Map) {
        super.mapping(map: map)
        
        png <- (map["png"], Message.pngBase64transform)
        urlString <- map["urlString"]
        printRequestId <- map["externalPrintJobId"]
        printer <- (map["printer"], Message.printerTransform)
    }
}
