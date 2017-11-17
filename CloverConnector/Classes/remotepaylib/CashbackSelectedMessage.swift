//
//  CashbackSelectedMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class CashbackSelectedMessage : Message {
    
    public var cashbackAmount:Int?
    
    public required init?(map:Map) {
        super.init(method: Method.CASHBACK_SELECTED)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        cashbackAmount <- map["cashbackAmount"]
    }
}
