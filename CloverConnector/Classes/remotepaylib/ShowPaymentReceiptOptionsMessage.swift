//
//  ShowPaymentReceiptOptionsMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper
//import CloverSDK

public class ShowPaymentReceiptOptionsMessage : Message {
    public var paymentId:String?
    public var orderId:String?
    
    public init() {
        super.init(method: .SHOW_PAYMENT_RECEIPT_OPTIONS)
    }
    
    public required init?(map:Map) {
        super.init(method: .SHOW_PAYMENT_RECEIPT_OPTIONS)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        paymentId <- map["paymentId"]
        orderId <- map["orderId"]
    }
}
