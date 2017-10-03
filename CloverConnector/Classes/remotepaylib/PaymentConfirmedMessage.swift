//
//  PaymentConfirmedMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper
//import CloverSDK

public class PaymentConfirmedMessage : Message
{
    public var payment:CLVModels.Payments.Payment?
    
    public init() {
        super.init(method: .PAYMENT_CONFIRMED)
    }
    public required init?(map:Map) {
        super.init(method: Method.PAYMENT_CONFIRMED)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        payment <- (map["payment"], Message.paymentTransform)
    }
}

public class PaymentRejectedMessage : Message
{
    public var payment:CLVModels.Payments.Payment?
    public var reason:VoidReason?
    
    public init() {
        super.init(method: .PAYMENT_REJECTED)
    }
    
    public required init?(map:Map) {
        super.init(method: Method.PAYMENT_REJECTED)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        payment <- (map["payment"], Message.paymentTransform)
        reason <- map["reason"]
    }
}
