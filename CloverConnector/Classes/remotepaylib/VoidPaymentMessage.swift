//
//  VoidPaymentMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper
//import CloverSDK

public class VoidPaymentMessage : Message {
    public var payment:CLVModels.Payments.Payment?
    public var voidReason:VoidReason?
    
    
    public init() {
        super.init(method: .VOID_PAYMENT)
    }
    
    public required init?(map:Map) {
        super.init(method: .VOID_PAYMENT)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        payment <- (map["payment"], Message.paymentTransform)
        voidReason <- map["voidReason"]
    }
}
