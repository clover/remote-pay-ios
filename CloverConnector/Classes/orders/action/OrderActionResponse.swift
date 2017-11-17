//
//  OrderActionResponse.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class OrderActionResponse : Mappable {
    public var id:String?
    public var accepted:Bool?
    
    public required init?(map:Map) {
        
    }
    
    public func mapping(map:Map) {
        id <- map["id"]
        accepted <- map["accepted"]
    }
}
