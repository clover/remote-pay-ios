//  
//  VoidPaymentRefundRequest.swift
//  CloverConnector
//
//  
//

import Foundation
import ObjectMapper

public class VoidPaymentRefundRequest: NSObject, Mappable {
    
    var refundId: String
    var employeeId: String?
    var orderId: String?
    var disablePrinting: Bool?
    var disableReceiptSelection: Bool?
    
    /// Extra pass-through data used by external systems. Currently unused. Full support coming in a future release.
//    public var extras: [String: String]?
    
    public required init(refundId: String, employeeId: String?, orderId: String?, disablePrinting: Bool?, disableReceiptSelection: Bool?) {
        self.refundId = refundId
        self.employeeId = employeeId
        self.orderId = orderId
        self.disablePrinting = disablePrinting
        self.disableReceiptSelection = disableReceiptSelection
        super.init()
    }
    
    public func mapping(map: Map) {
        refundId <- map["refundId"]
        orderId <- map["orderId"]
        employeeId <- map["employeeId"]
        disablePrinting <- map["disablePrinting"]
        disableReceiptSelection <- map["disableReceiptSelection"]
//        extras <- map["extras"]
    }
    
    //The required initializer to conform to <Mappable>. Probably won't ever be used because we'll use one of the other two initialiers
    public required init?(map: Map) {
        self.refundId = ""
        super.init()
    }
}
