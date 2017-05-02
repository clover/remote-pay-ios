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
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(track1, forKey: "track1")
        aCoder.encodeObject(track2, forKey: "track2")
        aCoder.encodeObject(track3, forKey: "track3")
        aCoder.encodeObject(encrypted, forKey: "encrypted")
        aCoder.encodeObject(maskedTrack1, forKey: "maskedTrack1")
        aCoder.encodeObject(maskedTrack2, forKey: "maskedTrack2")
        aCoder.encodeObject(maskedTrack3, forKey: "maskedTrack3")
        aCoder.encodeObject(pan, forKey: "pan")
        aCoder.encodeObject(cardholderName, forKey: "cardholderName")
        aCoder.encodeObject(firstName, forKey: "firstName")
        aCoder.encodeObject(lastName, forKey: "lastName")
        aCoder.encodeObject(exp, forKey: "exp")
        aCoder.encodeObject(last4, forKey: "last4")
        aCoder.encodeObject(first6, forKey: "first6")
        
    }
    
    required public init(coder aDecoder: NSCoder) {
        track1 = aDecoder.decodeObjectForKey("track1") as? String
        track2 = aDecoder.decodeObjectForKey("track2") as? String
        track3 = aDecoder.decodeObjectForKey("track3") as? String
        encrypted = aDecoder.decodeObjectForKey("encrypted") as? Bool
        maskedTrack1 = aDecoder.decodeObjectForKey("maskedTrack1") as? String
        maskedTrack2 = aDecoder.decodeObjectForKey("maskedTrack2") as? String
        maskedTrack3 = aDecoder.decodeObjectForKey("maskedTrack3") as? String
        pan = aDecoder.decodeObjectForKey("pan") as? String
        cardholderName = aDecoder.decodeObjectForKey("cardholderName") as? String
        firstName = aDecoder.decodeObjectForKey("firstName") as? String
        lastName = aDecoder.decodeObjectForKey("lastName") as? String
        exp = aDecoder.decodeObjectForKey("exp") as? String
        last4 = aDecoder.decodeObjectForKey("last4") as? String
        first6 = aDecoder.decodeObjectForKey("first6") as? String
    }
    
    override public init() {}
    
    required public init?(_ map:Map) {}
    
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
