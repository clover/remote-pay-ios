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
    public var externalId:String?
    
    public required init?(_ map:Map) {
        super.init(method: Method.TX_START_RESPONSE)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map)
        order <- (map["order"], Message.orderTransform)
        result <- map["result"]
        externalId <- map["externalId"]
    }
}

