//
//  OrderActionRemoveLineItemMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class OrderActionRemoveLineItemMessage : Message {
    public var removeLineItem:RemoveLineItemAction?
    
    public required init?(map:Map) {
        super.init(method: .ORDER_ACTION_REMOVE_LINE_ITEM)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        removeLineItem <- map["removeLineItem"]
    }
}
