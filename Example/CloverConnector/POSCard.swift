//
//  POSCard.swift
//  ExamplePOS
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation

public class POSCard {
    public var name:String?
    public var first6:String
    public var last4:String
    public var month:String
    public var year:String
    public var token:String?
    
    public init(name:String?, first6:String, last4:String, month:String, year:String, token:String?) {
        self.name = name
        self.first6 = first6
        self.last4 = last4
        self.month = month
        self.year = year
        self.token = token
    }

}
