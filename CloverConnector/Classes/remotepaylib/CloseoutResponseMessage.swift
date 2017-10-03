//
//  CloseoutResponseMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper
//import CloverSDK

public class CloseoutResponseMessage : Message {
    
    public var status:ResultStatus?
    public var reason:String?
    public var batch:CLVModels.Payments.Batch?
    
    public required init?(map:Map) {
        super.init(method: .CLOSEOUT_RESPONSE)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        status <- map["status"]
        reason <- map["reason"]
        batch <- map["batch"]
    }
}
