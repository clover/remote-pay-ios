//
//  POSLineItem.swift
//  ExamplePOS
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation

public class POSLineItem {
    public let item:POSItem
    public var quantity:Int = 1
    
    public var discount:POSDiscount?
    
    init(item:POSItem) {
        self.item = item
    }
    
    public func increment() {
        quantity += 1
    }
    
    public func decrement() {
        quantity -= 1
    }
    
    public func addDiscount(_ discount:POSDiscount) {
        self.discount = discount
    }
    
    public func removeDiscount(_ discount:POSDiscount) {
        self.discount = nil
    }
    
    public func afterDiscountPrice() -> Int{
        var discountAmount = item.price
        if let discount = discount {
            discountAmount = discount.calculateAmountOff(item.price)
        }
        return discountAmount
    }
}
