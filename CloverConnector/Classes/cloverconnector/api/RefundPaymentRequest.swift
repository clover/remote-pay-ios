//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import ObjectMapper

/**
 options for refunding a payment
 */
public class RefundPaymentRequest: NSObject, Mappable {
    
    /**
     * Amount to be refunded
     */
    public var amount:Int? = nil
    /**
     * Unique order identifier
     */
    public var orderId:String?
    /**
     * Unique payment identifier
     */
    public var paymentId:String?
    public var disablePrinting: Bool = false
    public var disableReceiptSelection: Bool = false
    
    /// Extra pass-through data used by external systems. Currently unused. Full support coming in a future release.
//    public var extras: [String: String]?
    
    /**
     * if fullRefund is true, the amount will be ignored. If fullRefund is false,
     * the amount must be provided
     */
    public var fullRefund:Bool?
    
    public init(orderId:String?, paymentId:String?, amount:Int?, fullRefund:Bool?) {
        self.orderId = orderId
        self.paymentId = paymentId
        self.amount = amount
        self.fullRefund = fullRefund
    }
    
    public init(orderId:String?, paymentId:String?, amount:Int) {
        self.orderId = orderId
        self.paymentId = paymentId
        self.amount = amount
    }
    
    public init(orderId: String?, paymentId:String?, fullRefund:Bool) {
        self.orderId = orderId
        self.paymentId = paymentId
        self.amount = nil
        self.fullRefund = fullRefund
    }
    
    /// :nodoc:
    public required init?(map:Map) {
        super.init()
    }
    
    /// :nodoc:
    public func mapping(map:Map) {
        amount <- map["amount"]
        orderId <- map["orderId"]
        paymentId <- map["paymentId"]
        fullRefund <- map["fullRefund"]
        disablePrinting <- map["disablePrinting"]
        disableReceiptSelection <- map["disableReceiptSelection"]
//        extras <- map["extras"]
    }
}

