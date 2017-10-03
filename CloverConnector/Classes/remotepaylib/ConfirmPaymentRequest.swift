//
//  ConfirmPaymentRequest.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class ConfirmPaymentRequest:NSObject, Mappable {
    public var payment:CLVModels.Payments.Payment? = nil
    public var challenges:[Challenge]? = nil
    public override init() {
        super.init()
    }
    
    required public init?(map:Map) {
        super.init()
    }
    public func mapping(map:Map) {
        payment <- (map["payment"], Message.paymentTransform)
        challenges <- map["challenges"]
    }
}
