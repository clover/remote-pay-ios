//
//  POSNakedRefund.swift
//  CloverConnector
//
//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation

public class POSNakedRefund {
    var employeeId:String
    var date:Date?
    var amount:Int
    
    init(employeeId:String, amount:Int) {
        self.employeeId = employeeId
        self.amount = amount
    }
}
