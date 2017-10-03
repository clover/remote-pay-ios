//
//  TxStartResponseMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper
//import CloverSDK

public class TxStartResponseMessage : Message {
    public var order:CLVModels.Order.Order?
    public var result:TxStartResponseResult?
    public var externalPaymentId:String?
    public var requestInfo:String?
    
    public required init?(map:Map) {
        super.init(method: Method.TX_START_RESPONSE)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        order <- (map["order"], Message.orderTransform)
        result <- map["result"]
        externalPaymentId <- map["externalPaymentId"]
        requestInfo <- map["requestInfo"]
    }
}

