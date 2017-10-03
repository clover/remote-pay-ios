//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper


/**
 response to a void payment request
 */
public class VoidPaymentResponse:BaseResponse {

    /// the id of the voided payment
  public var paymentId:String?
    /// :nodoc:
    public var transactionNumber:String?
    /// the reason for the void
    public var voidReason:VoidReason?
    
    public init(success:Bool, result:ResultCode, paymentId:String?, transactionNumber:String?) {
        super.init(success: success, result: result)
        self.paymentId = paymentId
        self.transactionNumber = transactionNumber
    }
    /// :nodoc:
    required public init?(map:Map) {
        super.init(map: map)
    }
    /// :nodoc:
    public override func mapping(map:Map) {
        super.mapping(map: map)
        paymentId <- map["paymentId"]
        transactionNumber <- map["transactionNumber"]
        voidReason <- map["voidReason"]
    }

}

