//
//  RefundResponseMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper
//import CloverSDK

public class RefundResponseMessage : Message {
    public var orderId:String?
    public var paymentId:String?
    public var refund:CLVModels.Payments.Refund?
    public var reason:ErrorCode?
    public var message:String?
    public var code:TxState?
    
    public required init?(map:Map) {
        super.init(method: Method.REFUND_RESPONSE)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        paymentId <- map["paymentId"]
        orderId <- map["orderId"]
        refund <- (map["refund"], Message.refundTransform)
        reason <- map["reason"]
        message <- map["message"]
        code <- map["code"]
    }
}
