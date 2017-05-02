//
//  TxStartRequestMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import ObjectMapper

public class TxStartRequestMessage : Message {

    public var payIntent:PayIntent?
    public var order:CLVModels.Order.Order?
    public var suppressOnScreenTips:Bool?
    
    public required init?(_ map:Map) {
        super.init(method: .TX_START)
    }
    
    public required init() {
        super.init(method: .TX_START)
    }
    
    public required convenience init(payIntent:PayIntent, order:CLVModels.Order.Order, suppressOnScreenTips:Bool) {
        self.init()
        self.payIntent = payIntent;
        self.order = order;
        self.suppressOnScreenTips = suppressOnScreenTips;
    }
    
    public override func mapping(map:Map) {
        super.mapping(map)

        payIntent <- map["payIntent"]
        order <- (map["order"], Message.orderTransform)
        suppressOnScreenTips <- map["suppressOnScreenTips"]
    }
}
