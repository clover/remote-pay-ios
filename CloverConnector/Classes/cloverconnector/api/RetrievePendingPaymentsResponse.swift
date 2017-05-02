//
//  RetrievePendingPaymentsResponse.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import ObjectMapper


public class RetrievePendingPaymentsResponse:BaseResponse {
    public var pendingPayments:[PendingPaymentEntry]?
    
    public init(code:ResultCode, message:String, payments:[PendingPaymentEntry]?) {
        super.init(success: code == ResultCode.SUCCESS, result: code);
        pendingPayments = payments
    }
    
    required public init?(_ map: Map) {
        super.init(map)
    }
    
    public override func mapping(map: Map) {
        super.mapping(map)
        pendingPayments <- map["pendingPayments"]
    }

}
