//
//  AddLineItemAction.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class AddLineItemAction : Mappable {
    public var lineItem:DisplayLineItem?
    
    public required init?(map:Map) {
        
    }
    
    public func mapping(map:Map) {
        lineItem <- map["lineItem"]
    }
}
