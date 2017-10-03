//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import ObjectMapper

/**
 * resopnse to a retrieve pending payments request
 */
public class RetrievePendingPaymentsResponse:BaseResponse {
    /// list of payments in the queue, that have not been sent to the server for processing
    public var pendingPayments:[PendingPaymentEntry]?
    
    public init(code:ResultCode, message:String, payments:[PendingPaymentEntry]?) {
        super.init(success: code == ResultCode.SUCCESS, result: code);
        pendingPayments = payments
    }
    
    /// :nodoc:
    required public init?(map:Map) {
        super.init(map: map)
    }
    /// :nodoc:
    public override func mapping(map:Map) {
        super.mapping(map: map)
        pendingPayments <- map["pendingPayments"]
    }

}
