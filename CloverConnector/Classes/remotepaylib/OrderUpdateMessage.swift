//
//  OrderUpdateMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class OrderUpdateMessage : Message {
    
    public var displayOrder:DisplayOrder?
    //public var order:String?
    public var operation:DisplayOrderModifiedOperation?
    
    public init() {
        super.init(method: .SHOW_ORDER_SCREEN)
    }
    
    public init(displayOrder:DisplayOrder, operation:DisplayOrderModifiedOperation?) {
        super.init(method: .SHOW_ORDER_SCREEN)
        
        self.displayOrder = displayOrder
        self.operation = operation
    }
    
    public required init?(map:Map) {
        super.init(method: .SHOW_ORDER_SCREEN)
        
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)

        displayOrder <- (map["order"], Message.displayOrderTransform)
    }
}
