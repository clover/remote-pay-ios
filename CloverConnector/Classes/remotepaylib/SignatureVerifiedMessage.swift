//
//  SignatureVerifiedMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper
//import CloverSDK

public class SignatureVerifiedMessage : Message {
    
    public var payment:CLVModels.Payments.Payment?
    public var verified:Bool = false
    
    public required init() {
        super.init(method: .SIGNATURE_VERIFIED)
    }
    required public init?(map:Map) {
        super.init(method: .SIGNATURE_VERIFIED)
    }
    public init(payment:CLVModels.Payments.Payment, verified:Bool) {
        super.init(method: .SIGNATURE_VERIFIED)
        
        self.payment = payment
        self.verified = verified
    }
    public override func mapping(map:Map) {
        super.mapping(map: map)
        payment <- (map["payment"], Message.paymentTransform)
        verified <- map["verified"]
    }
}
