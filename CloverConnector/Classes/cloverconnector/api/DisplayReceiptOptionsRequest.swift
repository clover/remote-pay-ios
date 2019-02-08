//  
//  DisplayReceiptOptionsRequest.swift
//  CloverConnector
//
//  
//

import Foundation
import ObjectMapper

public class DisplayReceiptOptionsRequest: NSObject, Mappable {
    public var orderId: String?
    public var paymentId: String?
    public var refundId: String?
    public var creditId: String?
    public var disablePrinting: Bool?
    
    public override init() {
        super.init()
    }
    
    public required init?(map: Map) { }
    
    public func mapping(map: Map) {
        orderId <- map["orderId"]
        paymentId <- map["paymentId"]
        refundId <- map["refundId"]
        creditId <- map["creditId"]
        disablePrinting <- map["disablePrinting"]
    }
}
