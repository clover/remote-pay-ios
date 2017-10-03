//
//  OrderActionResponseMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class OrderActionResponseMessage : Message {
    public var orderActionResponse:OrderActionResponse?
    
    public required init?(map:Map) {
        super.init(method: .ORDER_ACTION_RESPONSE)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        orderActionResponse <- map["orderActionResponse"]
    }
}
