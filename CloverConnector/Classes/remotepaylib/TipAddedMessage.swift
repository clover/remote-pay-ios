//
//  TipAddedMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class TipAddedMessage : Message {
    
    public var tipAmount:Int?
    
    public required init?(map:Map) {
        super.init(method: Method.TIP_ADDED)
    }
    
    public init(_ tip:Int) {
        super.init(method: Method.TIP_ADDED)
        tipAmount = tip
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        tipAmount <- map["tipAmount"]
    }
}
