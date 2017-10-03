//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import ObjectMapper

/**
 options for capturing a pre-auth
 */
public class CapturePreAuthRequest : NSObject, Mappable {

  /**
  * Total amount paid
   */
  public var amount:Int
  /**
  * Amount paid in tips
   */
  public var tipAmount:Int? = nil
  /**
  * Unique identifier
   */
  public var paymentId:String

    public required init(amount:Int, paymentId:String) {
        self.amount = amount
        self.paymentId = paymentId

  }

    /// :nodoc:
    public required init?(map:Map) {
        amount = 0
        paymentId = ""
        super.init()
    }

    /// :nodoc:
    public func mapping(map:Map) {
        amount <- map["amount"]
        tipAmount <- map["tipAmount"]
        paymentId <- map["paymentId"]
    }

}
