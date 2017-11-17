//
//  LineItemsAddedOperation.swift
//  CloverSDKOrder
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper



public class DisplayOrderModifiedOperation : Mappable {
    public var ids:Array<String>?
    public var orderId:String?
    
    public required init?(map:Map) {
        
    }
    
    public init(id:String) {
        self.ids = [id]
    }
    
    public func mapping(map:Map) {
        ids <- map["ids"]
        orderId <- map["orderId"]
    }
}

public class LineItemsAddedOperation : DisplayOrderModifiedOperation {
    
}

public class LineItemsDeletedOperation : DisplayOrderModifiedOperation {
    
}

public class DiscountsAddedOperation : DisplayOrderModifiedOperation {
    
}

public class DiscountsRemovedOperation : DisplayOrderModifiedOperation {
    
}
