//
//  RetrievePrintersResponseMessage.swift
//  Pods
//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//


import Foundation

import ObjectMapper


public class RetrievePrintersResponseMessage : Message {
    
    public var printers:[CLVModels.Printer.Printer]?
    
    public init() {
        super.init(method: .GET_PRINTERS_RESPONSE)
    }
    
    public required init?(map:Map) {
        super.init(method: .GET_PRINTERS_RESPONSE)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        
        printers <- (map["printers"], Message.printerTransform)
    }
}
