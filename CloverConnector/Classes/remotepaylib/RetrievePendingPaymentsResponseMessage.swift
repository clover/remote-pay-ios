//
//  RetrievePendingPaymentsResponseMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper
//import CloverSDK

class RetrievePendingPaymentsResponseMessage : Message
{
    public var pendingPaymentEntries:[PendingPaymentEntry]?
    public var status:ResultStatus?
    public var reason:String?
    
    public required init?(map:Map) {
        super.init(method: Method.RETRIEVE_PENDING_PAYMENTS_RESPONSE)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        pendingPaymentEntries <- map["pendingPaymentEntries"]
        status <- map["status"]
        reason <- map["reason"]
    }
}
