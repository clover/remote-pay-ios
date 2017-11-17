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
    }

}

