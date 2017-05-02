//
//  OpenCashDrawerMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation

import ObjectMapper

public class OpenCashDrawerMessage : Message {
    public var reason:String?
    
    public init() {
        super.init(method: .OPEN_CASH_DRAWER)
    }
    public required init?(_ map:Map) {
        super.init(method: .OPEN_CASH_DRAWER)
    }
    
    public override func mapping(map: Map) {
        super.mapping(map)
        reason <- map["reason"]
    }
    
}
