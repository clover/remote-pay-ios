//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import ObjectMapper

/**
 options for void payment request
 */
public class VoidPaymentRequest:NSObject, Mappable {
    
    /*
     * Unique identifier
     */
    var orderId:String? = nil
    /*
     * Unique identifier
     */
    var paymentId:String?
    /// reason for voiding a payment
    var voidReason:VoidReason
    public var disablePrinting: Bool = false
    public var disableReceiptSelection: Bool = false
    
    /// Extra pass-through data used by external systems. Currently unused. Full support coming in a future release.
//    public var extras: [String: String]?
    
    public required init(orderId:String, paymentId:String, voidReason:VoidReason) {
        self.orderId = orderId
        self.paymentId = paymentId
        self.voidReason = voidReason
        super.init()
    }
        
    /// :nodoc:
    public required init?(map:Map) {
        voidReason = .USER_CANCEL
        super.init()
    }
    /// :nodoc:
    public func mapping(map:Map) {
        
        orderId <- map["orderId"]
        paymentId <- map["paymentId"]
        voidReason <- map["voidReason"]
        disablePrinting <- map["disablePrinting"]
        disableReceiptSelection <- map["disableReceiptSelection"]
//        extras <- map["extras"]
    }
}

