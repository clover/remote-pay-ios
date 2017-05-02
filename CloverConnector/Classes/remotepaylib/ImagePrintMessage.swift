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

    public init() {
        super.init(method: Method.PRINT_IMAGE)
    }
    
    public required init?(_ map:Map) {
        super.init(method: Method.PRINT_IMAGE)
    }

    public override func mapping(map:Map) {
        super.mapping(map)
        
       png <- (map["png"], Message.pngBase64transform)
       urlString <- map["urlString"]
    }
}
