//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import ObjectMapper

/**
 options for a request to read card data 
 */
public class ReadCardDataRequest:NSObject, Mappable
{
    /**
     * Allowed entry methods. Constants defined in CloverConnector can be OR'd togethers
     */
    public var cardEntryMethods:Int? = 34567
    
    /// :nodoc:
    public var forceSwipePinEntry:Bool = false;
    
    public required override init() {
        super.init()
    }
    
    /// :nodoc:
    required public init?(map:Map) {
        super.init()
    }
    
    /// :nodoc:
    public func mapping(map:Map) {
        forceSwipePinEntry <- map["isForceSwipePinEntry"]
        cardEntryMethods <- map["cardEntryMethods"]
    }
    
}
