//
//  PartialAuthMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class PartialAuthMessage : Message {
    public var partialAuthAmount:Int?
    
    public required init?(map:Map) {
        super.init(method: Method.PARTIAL_AUTH)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        partialAuthAmount <- map["partialAuthAmount"]
    }
}
