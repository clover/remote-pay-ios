//
//  POSItem.swift
//  ExamplePOS
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation

public class POSItem {
    public var name:String?
    public var price:Int = 0
    public var taxable = true
    public var taxRate:Float = 0
    public var tippable:Bool = true
    public var id:String
    
    public init(id:String, name:String, price:Int, taxRate:Float, taxable:Bool = true, tippable:Bool = true) {
        self.id = id
        self.name = name
        self.price = price
        self.taxRate = taxRate
        self.taxable = taxable
        self.tippable = tippable
    }
    
}
