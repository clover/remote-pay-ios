//
//  POSExchange.swift
//  ExamplePOS
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation

public class POSExchange {
    public var paymentId:String
    public var orderId:String
    public var employeeId:String
    public var amount:Int
    
    public init(orderId:String, paymentId:String, employeeId:String, amount:Int) {
        self.orderId = orderId
        self.paymentId = paymentId
        self.employeeId = employeeId
        self.amount = amount
    }
}
