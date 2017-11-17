//
//  PaymentPrintMerchantCopyMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
//import CloverSDK
import ObjectMapper

public class PaymentPrintMerchantCopyMessage:Message {
    public var payment:CLVModels.Payments.Payment?
    
    public required init?(map:Map) {
        super.init(method:.PRINT_PAYMENT_MERCHANT_COPY)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        payment <- (map["payment"], Message.paymentTransform)
    }
}
