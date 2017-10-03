//
//  CardDataRequestMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class CardDataRequestMessage:Message {
    public var payIntent:PayIntent?
    
    public init() {
        super.init(method: .CARD_DATA)
    }
    
    public required init?(map:Map) {
        super.init(method: .CARD_DATA)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        payIntent <- map["payIntent"]
    }
}
