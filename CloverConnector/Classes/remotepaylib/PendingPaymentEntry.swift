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
    
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(paymentId, forKey: "paymentId")
        aCoder.encode(amount, forKey: "amount")
    }
    
    required public init(coder aDecoder: NSCoder) {
        paymentId = aDecoder.decodeObject(forKey: "paymentId") as? String
        amount = aDecoder.decodeObject(forKey: "amount") as? Int
    }
    
    override public init() {}
    
    required public init?(map:Map) {}
    
    public func mapping(map:Map) {
        paymentId <- map["paymentId"]
        amount <- map["amount"]
    }
}
