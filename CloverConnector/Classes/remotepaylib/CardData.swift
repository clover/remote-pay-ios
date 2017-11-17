//
//  CardData.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class CardData:NSObject, NSCoding, Mappable {
    public var track1:String?
    public var track2:String?
    public var track3:String?
    public var encrypted:Bool?
    public var maskedTrack1:String?
    public var maskedTrack2:String?
    public var maskedTrack3:String?
    public var pan:String?
    public var cardholderName:String?
    public var firstName:String?
    public var lastName:String?
    public var exp:String?
    public var last4:String?
    public var first6:String?
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(track1, forKey: "track1")
        aCoder.encode(track2, forKey: "track2")
        aCoder.encode(track3, forKey: "track3")
        aCoder.encode(encrypted, forKey: "encrypted")
        aCoder.encode(maskedTrack1, forKey: "maskedTrack1")
        aCoder.encode(maskedTrack2, forKey: "maskedTrack2")
        aCoder.encode(maskedTrack3, forKey: "maskedTrack3")
        aCoder.encode(pan, forKey: "pan")
        aCoder.encode(cardholderName, forKey: "cardholderName")
        aCoder.encode(firstName, forKey: "firstName")
        aCoder.encode(lastName, forKey: "lastName")
        aCoder.encode(exp, forKey: "exp")
        aCoder.encode(last4, forKey: "last4")
        aCoder.encode(first6, forKey: "first6")
        
    }
    
    required public init(coder aDecoder: NSCoder) {
        track1 = aDecoder.decodeObject(forKey: "track1") as? String
        track2 = aDecoder.decodeObject(forKey: "track2") as? String
        track3 = aDecoder.decodeObject(forKey: "track3") as? String
        encrypted = aDecoder.decodeObject(forKey: "encrypted") as? Bool
        maskedTrack1 = aDecoder.decodeObject(forKey: "maskedTrack1") as? String
        maskedTrack2 = aDecoder.decodeObject(forKey: "maskedTrack2") as? String
        maskedTrack3 = aDecoder.decodeObject(forKey: "maskedTrack3") as? String
        pan = aDecoder.decodeObject(forKey: "pan") as? String
        cardholderName = aDecoder.decodeObject(forKey: "cardholderName") as? String
        firstName = aDecoder.decodeObject(forKey: "firstName") as? String
        lastName = aDecoder.decodeObject(forKey: "lastName") as? String
        exp = aDecoder.decodeObject(forKey: "exp") as? String
        last4 = aDecoder.decodeObject(forKey: "last4") as? String
        first6 = aDecoder.decodeObject(forKey: "first6") as? String
    }
    
    override public init() {}
    
    required public init?(map:Map) {}
    
    public func mapping(map:Map) {
        track1 <- map["track1"]
        track2 <- map["track2"]
        track3 <- map["track3"]
        encrypted <- map["encrypted"]
        maskedTrack1 <- map["maskedTrack1"]
        maskedTrack2 <- map["maskedTrack2"]
        maskedTrack3 <- map["maskedTrack3"]
        pan <- map["pan"]
        cardholderName <- map["cardholderName"]
        firstName <- map["firstName"]
        lastName <- map["lastName"]
        exp <- map["exp"]
        last4 <- map["last4"]
        first6 <- map["first6"]
    }
}
