//
//  CapturePreAuthMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class CapturePreAuthRequestMessage:Message {
    
    public var paymentId:String?
    public var amount:Int?
    public var tipAmount:Int?
    
    public init() {
        super.init(method: .CAPTURE_PREAUTH)
    }
    
    public required init?(map:Map) {
        super.init(method: .CAPTURE_PREAUTH)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        paymentId <- map["paymentId"]
        amount <- map["amount"]
        tipAmount <- map["tipAmount"]
       
    }
}
