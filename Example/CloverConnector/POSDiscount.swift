//
//  POSDiscount.swift
//  ExamplePOS
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation


public class POSDiscount {
    public var description:String?
    public var amount:Int?
    public var percentOff:Int? // 10000 is 10 percent off, 125 is 1/8% off
    
    public func calculateAmountOff(_ baseAmount:Int) -> Int {
    var amountOff = 0
        if let amount = amount {
            amountOff = max(baseAmount, amount)
        } else if let percentOff = percentOff {
            amountOff = /*round*/((baseAmount * percentOff/1000/100)) as Int
        }
        return amountOff
    }
}
