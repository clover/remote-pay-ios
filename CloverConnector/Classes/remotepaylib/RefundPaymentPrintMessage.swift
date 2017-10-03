//
//  RefundPaymentPrintMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper
//import CloverSDK

public class RefundPaymentPrintMessage : Message {
    public var payment:CLVModels.Payments.Payment?
    public var refund:CLVModels.Payments.Refund?
    public var order:CLVModels.Order.Order?
    
    public required init?(map:Map) {
        super.init(method: .REFUND_PRINT_PAYMENT)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        payment <- (map["payment"], Message.paymentTransform)
        refund <- (map["refund"], Message.refundTransform)
        order <- (map["order"], Message.orderTransform)
    }
}
