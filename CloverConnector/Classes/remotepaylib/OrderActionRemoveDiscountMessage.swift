//
//  OrderActionRemoveDiscountMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class OrderActionRemoveDiscountMessage : Message {
    public var removeDiscountAction:RemoveDiscountAction?
    
    public required init?(map:Map) {
        super.init(method: .ORDER_ACTION_REMOVE_DISCOUNT)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        removeDiscountAction <- map["removeDiscountAction"]
    }
}
