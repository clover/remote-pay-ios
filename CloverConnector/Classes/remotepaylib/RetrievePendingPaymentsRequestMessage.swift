//
//  RetrievePendingPaymentsRequestMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class RetrievePendingPaymentsRequestMessage : Message
{
    public init() {
        super.init(method: .RETRIEVE_PENDING_PAYMENTS)
    }
    public required init?(map:Map) {
        super.init(method: Method.RETRIEVE_PENDING_PAYMENTS)
    }

}
