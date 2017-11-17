//
//  RefundRequestMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class RefundRequestMessage : Message {
    public var orderId:String?
    public var paymentId:String?
    public var amount:Int?
    public var fullRefund:Bool?
    
    public init(orderId:String, paymentId:String, amount:Int?, fullRefund:Bool?) {
        super.init(method: .REFUND_REQUEST)
        self.orderId = orderId
        self.paymentId = paymentId
        self.amount = amount
        self.fullRefund = fullRefund
    }
    public required init?(map:Map) {
        super.init(method: .REFUND_REQUEST)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        orderId <- map["orderId"]
        paymentId <- map["paymentId"]
        amount <- map["amount"]
        fullRefund <- map["fullRefund"]
    }
}
