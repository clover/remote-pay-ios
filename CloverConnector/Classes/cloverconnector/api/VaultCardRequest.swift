//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import ObjectMapper

/**
 options for a vault card request
 */
public class VaultCardRequest : NSObject, Mappable {

    /*
     * Identifier for the request
     */
    var requestId:String? = nil
    /*
     * Allowed entry methods
     */
    public var cardEntryMethods:Int? = 34567
    
    public required override init() {
        super.init()
    }
    
    /// :nodoc:
    required public init?(map:Map) {
    }
    
    public func mapping(map:Map) {
        requestId <- map["requestId"]
        
        cardEntryMethods <- map["cardEntryMethods"]
        
    }

}

