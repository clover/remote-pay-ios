//
//  OrderActionLineItemMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class OrderActionLineItemMessage : Message {
    public var addLineItemAction:AddLineItemAction?
    
    public required init?(map:Map) {
        super.init(method: .ORDER_ACTION_ADD_LINE_ITEM)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        addLineItemAction <- map["addLineItemAction"]
    }
}
