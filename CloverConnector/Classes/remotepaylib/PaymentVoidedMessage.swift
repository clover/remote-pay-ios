//
//  PaymentVoidedMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper
//import CloverSDK

public class PaymentVoidedMessage : Message {
    public var payment:CLVModels.Payments.Payment?
    public var voidReason:VoidReason?
    
    public required init?(map:Map) {
        super.init(method: .PAYMENT_VOIDED)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        payment <- (map["payment"], Message.paymentTransform)
        voidReason <- map["voidReason"]
    }
}
