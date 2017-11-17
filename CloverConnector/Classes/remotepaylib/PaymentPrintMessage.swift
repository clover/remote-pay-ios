//
//  PaymentPrintMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper
//import CloverSDK

public class PaymentPrintMessage : Message {
    public var payment:CLVModels.Payments.Payment?
    public var order:CLVModels.Order.Order?
    
    public required init?(map:Map) {
        super.init(method: Method.PRINT_PAYMENT)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        payment <- (map["payment"], Message.paymentTransform)
        order <- (map["order"], Message.orderTransform)
    }
}
