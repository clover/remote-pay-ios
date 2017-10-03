//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import ObjectMapper

/**
 options for a tip adjust request
 */
public class TipAdjustAuthRequest : NSObject, Mappable {

    /**
     * Amount paid in tips
     */
    public var tipAmount:Int
    /**
     * Unique identifier
     */
    public var orderId:String
    /**
     * Unique identifier
     */
    public var paymentId:String
    
    public required init(orderId: String, paymentId: String, tipAmount:Int) {
        self.tipAmount = tipAmount
        self.orderId = orderId
        self.paymentId = paymentId
    }
    
    /// :nodoc:
    public required init?(map:Map) {
        orderId = ""
        paymentId = ""
        tipAmount = 0
        super.init()
    }
    
    /// :nodoc:
    public func mapping(map:Map) {
        tipAmount <- map["tipAmount"]
        orderId <- map["orderId"]
        paymentId <- map["orderId"]
    }

}

