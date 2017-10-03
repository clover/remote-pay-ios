//
//  DeclineCreditPrintMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
//import CloverSDK
import ObjectMapper

public class DeclineCreditPrintMessage:Message {
    public var credit:CLVModels.Payments.Credit?
    public var reason:String?
    
    public required init?(map:Map) {
        super.init(method: .PRINT_CREDIT_DECLINE)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        credit <- (map["credit"], Message.creditTransform)
        reason <- map["reason"]
    }
}

