//
//  PendingPaymentEntry.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class PendingPaymentEntry : NSObject, NSCoding, Mappable {
    public var paymentId:String?
    public var amount:Int?
    
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(paymentId, forKey: "paymentId")
        aCoder.encodeObject(amount, forKey: "amount")
    }
    
    required public init(coder aDecoder: NSCoder) {
        paymentId = aDecoder.decodeObjectForKey("paymentId") as? String
        amount = aDecoder.decodeObjectForKey("amount") as? Int
    }
    
    override public init() {}
    
    required public init?(_ map:Map) {}
    
    public func mapping(map:Map) {
        paymentId <- map["paymentId"]
        amount <- map["amount"]
    }
}
