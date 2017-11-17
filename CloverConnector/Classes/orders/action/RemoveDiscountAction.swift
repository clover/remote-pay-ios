//
//  RemoveDiscountAction.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class RemoveDiscountAction : Mappable {
    public var discount:DisplayDiscount?
    
    public required init?(map:Map) {
        
    }
    
    public func mapping(map:Map) {
        discount <- map["discount"]
    }
}
