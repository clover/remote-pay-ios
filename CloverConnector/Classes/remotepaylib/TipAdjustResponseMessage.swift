//
//  TipAdjustResponseMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper
//import CloverSDK

public class TipAdjustResponseMessage : Message {
    public var orderId:String?
    public var paymentId:String?
    public var amount:Int?
    public var success:Bool?
    
    public required init?(map:Map) {
        super.init(method: Method.TIP_ADJUST_RESPONSE)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        paymentId <- map["paymentId"]
        orderId <- map["orderId"]
        amount <- map["amount"]
        success <- map["success"]
    }
}
