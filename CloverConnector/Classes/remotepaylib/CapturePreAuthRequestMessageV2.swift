//
//  CapturePreAuthMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2018 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class CapturePreAuthRequestMessageV2:Message {
    
    public var payIntent:PayIntent?
    public var order:CLVModels.Order.Order?
    public var requestInfo:String?
    
    public required init?(map:Map) {
        super.init(method: .CAPTURE_PREAUTH)
        self.version = 2
    }
    
    public required init() {
        super.init(method: .CAPTURE_PREAUTH)
        self.version = 2
    }
    
    public required convenience init(payIntent:PayIntent, order:CLVModels.Order.Order?, requestInfo ri:String?) {
        self.init()
        self.version = 2
        self.payIntent = payIntent
        self.order = order
        self.requestInfo = ri
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        
        payIntent <- map["payIntent"]
        order <- (map["order"], Message.orderTransform)
        requestInfo <- map["requestInfo"]
    }
}
