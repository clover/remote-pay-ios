//
//  POSRefund.swift
//  ExamplePOS
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation

public class POSRefund : POSExchange {
    public var refundId:String
    
    public init(refundId:String, paymentId:String, orderID:String, employeeId:String, amount:Int) {
        self.refundId = refundId
        super.init(orderId: orderID, paymentId: paymentId, employeeId: employeeId, amount: amount)
    }
}
