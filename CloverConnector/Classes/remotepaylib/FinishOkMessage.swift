//
//  FinishOkMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class FinishOkMessage : Message {
    public var payment:CLVModels.Payments.Payment?
    public var credit:CLVModels.Payments.Credit?
    public var refund:CLVModels.Payments.Refund?
    public var signature:Signature?
    
    required public init?(_ map: Map) {
        super.init(method: .FINISH_OK)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map)

        payment <- (map["payment"], Message.paymentTransform)
        credit <- (map["credit"], Message.creditTransform)
        refund <- (map["refund"], Message.refundTransform)
        signature <- map["signature"]
    }
}

