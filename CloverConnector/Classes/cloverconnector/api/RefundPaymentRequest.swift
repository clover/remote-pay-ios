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
  public var orderId:String
  /**
   * Unique payment identifier
   */
  public var paymentId:String
  /**
   * if fullRefund is true, the amount will be ignored. If fullRefund is false,
   * the amount must be provided
   */
  public var fullRefund:Bool = true

    public init(orderId:String, paymentId:String, amount:Int?, fullRefund:Bool?) {
        self.orderId = orderId
        self.paymentId = paymentId
        self.amount = amount
        self.fullRefund = fullRefund ?? false
    }
    
    public init(orderId:String, paymentId:String, amount:Int) {
        self.orderId = orderId
        self.paymentId = paymentId
        self.amount = amount
        self.fullRefund = false
    }
    
    public init(orderId: String, paymentId:String, fullRefund:Bool) {
        self.orderId = orderId
        self.paymentId = paymentId
        self.amount = nil
        self.fullRefund = true
    }
    
    /// :nodoc:
    public required init?(map:Map) {
        orderId = ""
        paymentId = ""
        super.init()
    }
    
    /// :nodoc:
    public func mapping(map:Map) {
        amount <- map["amount"]
        orderId <- map["orderId"]
        paymentId <- map["paymentId"]
        fullRefund <- map["fullRefund"]
    }
}

