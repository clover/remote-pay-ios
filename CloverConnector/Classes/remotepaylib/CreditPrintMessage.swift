//
//  CreditPrintMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
//import CloverSDK
import ObjectMapper

public class CreditPrintMessage:Message {
    public var credit:CLVModels.Payments.Credit?
    public required init?(map:Map) {
        super.init(method: .PRINT_CREDIT)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        credit <- (map["credit"], Message.creditTransform)
    }
}
