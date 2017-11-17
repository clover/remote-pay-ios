//
//  CapturePreAuthResponseMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class CapturePreAuthResponseMessage : Message {
    public var status:ResultStatus?
    public var reason:String?
    public var paymentId:String?
    public var amount:Int?
    public var tipAmount:Int?
    
    
    public required init?(map:Map) {
        super.init(method:.CAPTURE_PREAUTH_RESPONSE)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        status <- map["status"]
        reason <- map["reason"]
        paymentId <- map["paymentId"]
        amount <- map["amount"]
        tipAmount <- map["tipAmount"]
    }
}
