//
//  TxStartRequestMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import ObjectMapper

public class TxStartRequestMessage : Message {

    public static let SALE_REQUEST = "SALE";
    public static let AUTH_REQUEST = "AUTH";
    public static let PREAUTH_REQUEST = "PREAUTH";
    public static let CREDIT_REQUEST = "CREDIT";
    public static let REFUND_REQUEST = "REFUND";
    
    public var payIntent:PayIntent?
    public var order:CLVModels.Order.Order?
    public var suppressOnScreenTips:Bool?
    public var requestInfo:String?
    
    public required init?(map:Map) {
        super.init(method: .TX_START)
        self.version = 2
    }
    
    public required init() {
        super.init(method: .TX_START)
        self.version = 2
    }
    
    public required convenience init(payIntent:PayIntent, order:CLVModels.Order.Order, suppressOnScreenTips:Bool, requestInfo ri:String?) {
        self.init()
        self.version = 2
        self.payIntent = payIntent
        self.order = order
        self.suppressOnScreenTips = suppressOnScreenTips
        self.requestInfo = ri
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)

        payIntent <- map["payIntent"]
        order <- (map["order"], Message.orderTransform)
        suppressOnScreenTips <- map["suppressOnScreenTips"]
        requestInfo <- map["requestInfo"]
    }
}
