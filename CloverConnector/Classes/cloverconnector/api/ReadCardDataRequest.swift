//
//  ReadCardDataRequest.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import ObjectMapper

@objc
public class ReadCardDataRequest:NSObject, Mappable
{
    /*
     * Allowed entry methods
     */
    public var cardEntryMethods:Int? = 34567
    
    public var forceSwipePinEntry:Bool = false;
    
    public required override init() {
        super.init()
    }
    
    required public init?(_ map: Map) {
        super.init()
    }
    
    public func mapping(map:Map) {
        forceSwipePinEntry <- map["isForceSwipePinEntry"]
        cardEntryMethods <- map["cardEntryMethods"]
    }
    
}
