//
//  VoidPaymentResponseMessage.swift
//  CloverSDKRemotepay
//
//
//  Copyright © 2018 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class VoidPaymentResponseMessage : Message {
    public var payment:CLVModels.Payments.Payment?
    public var voidReason:VoidReason?
    public var success: Bool?
    public var status: ResultStatus?
    public var reason: String?
    public var message: String?
    
    public required init?(map:Map) {
        super.init(method: Method.VOID_PAYMENT_RESPONSE)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        payment <- (map["payment"], Message.paymentTransform)
        voidReason <- map["voidReason"]
        success <- map["success"]
        status <- map["status"]
        reason <- map["reason"]
        message <- map["message"]
    }
}
