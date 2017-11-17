//
//  RetrievePrintersRequestMessage.swift
//  Pods
//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//


import Foundation

import ObjectMapper


public class RetrievePrintersRequestMessage : Message {
    
    public var category:PrintCategory?
    
    public init() {
        super.init(method: .GET_PRINTERS_REQUEST)
    }
    
    public required init?(map:Map) {
        super.init(method: .GET_PRINTERS_REQUEST)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        category <- map["category"]
    }
}
