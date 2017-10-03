//
//  DeclinePaymentPrintMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
//import CloverSDK
import ObjectMapper

public class DeclinePaymentPrintMessage:Message {
    public var payment:CLVModels.Payments.Payment?
    public var reason:String?
    
    public required init?(map:Map) {
        super.init(method: .PRINT_PAYMENT_DECLINE)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        payment <- (map["payment"], Message.paymentTransform)
        reason <- map["reason"]
    }
}
