//
//  TipAdjustMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class TipAdjustMessage : Message {
    public var paymentId:String?
    public var orderId:String?
    public var tipAmount:Int?
    
    public init() {
        super.init(method: .TIP_ADJUST)
    }
    
    public required init?(map:Map) {
        super.init(method: .TIP_ADJUST)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        paymentId <- map["paymentId"]
        orderId <- map["orderId"]
        tipAmount <- map["tipAmount"]
    }
}
