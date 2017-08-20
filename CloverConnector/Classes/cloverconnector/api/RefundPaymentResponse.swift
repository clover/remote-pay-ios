//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import ObjectMapper

/**
 response to a refund payment request
 */
public class RefundPaymentResponse : BaseResponse {

  /*
  * The order for the refund
   */
  public var orderId:String?
  /*
  * The payment the refund was based on
   */
  public var paymentId:String?
  /*
  * The actual refund from the request
   */
  public var refund:CLVModels.Payments.Refund?

    public init(success:Bool, result:ResultCode, orderId:String?=nil, paymentId:String?=nil, refund:CLVModels.Payments.Refund?=nil) {
        super.init(success:success, result:result)
        // TODO these must be set if success
        self.orderId = orderId
        self.paymentId = paymentId
        self.refund = refund
    }
    /// :nodoc:
    required public init?(_ map: Map) {
        super.init(map)
    }
    /// :nodoc:
    public override func mapping(map: Map) {
        super.mapping(map)
        orderId <- map["orderId"]
        paymentId <- map["paymentId"]
        refund <- map["refund"]
    }

}

