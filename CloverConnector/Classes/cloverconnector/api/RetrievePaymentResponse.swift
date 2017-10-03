//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import ObjectMapper

/**
 response to a retrieve payment request
 */
public class RetrievePaymentResponse:BaseResponse {
    /**
     * the status of the payment
     * - FOUND - the payment has been processed
     * - NOT_FOUND - the payment can't be found on this device
     * - IN_PROGRESS - the device is currently operating on the payment
     */
    public var queryStatus:QueryStatus
    /// the request external payment id
    public var externalPaymentId:String?
    /// the payment object, if FOUND
    public var payment:CLVModels.Payments.Payment?
    
    public init(success s:Bool, result r:ResultCode, queryStatus qs:QueryStatus, payment p:CLVModels.Payments.Payment?, externalPaymentId epi:String?) {
        self.queryStatus = qs
        super.init(success: s, result: r)
        self.payment = p
        self.externalPaymentId = epi
    }
    /// :nodoc:
    required public init?(map:Map) {
        self.queryStatus = .NOT_FOUND
        super.init(success: false, result: .FAIL)
    }
    /// :nodoc:
    public override func mapping(map:Map) {
        super.mapping(map: map)
        self.payment <- map["payment"]
    }
}

/**
 status of the payment as requested
 */
public enum QueryStatus:String {
    case FOUND = "FOUND"
    case NOT_FOUND = "NOT_FOUND"
    case IN_PROGRESS = "IN_PROGRESS"
}
