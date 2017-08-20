//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import ObjectMapper

/**
 response to a tip adjust request
 */
public class TipAdjustAuthResponse : BaseResponse {

    /*
     * tip amount
     */
    public private(set) var tipAmount:Int?
    /**
     * The payment id from the authorization payment, or
     * captured pre-auth payment
     */
    public private(set) var paymentId:String?
    /// the order id of the payment
    public private(set) var orderId:String?

    public required init(success:Bool, result:ResultCode, paymentId:String?, tipAmount:Int?) {
        super.init(success: success, result:result)
        self.paymentId = paymentId
        self.tipAmount = tipAmount
  }
    /// :nodoc:
    required public init?(_ map: Map) {
        super.init(map)
    }
    /// :nodoc:
    public override func mapping(map: Map) {
        super.mapping(map)
        paymentId <- map["paymentId"]
        tipAmount <- map["tipAmount"]
        orderId <- map["orderId"]
    }

}

