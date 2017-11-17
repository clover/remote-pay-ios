//
//  CloseoutRequestMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation

import ObjectMapper

public class CloseoutRequestMessage : Message {
    
    public var allowOpenTabs:Bool?
    public var batchId:String?
    
    public init() {
        super.init(method: .CLOSEOUT_REQUEST)
    }
    
    public required init?(map:Map) {
        super.init(method: .CLOSEOUT_REQUEST)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        allowOpenTabs <- map["allowOpenTabs"]
        batchId <- map["batchId"]
    }
}
