//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import ObjectMapper

public class CustomActivityRequest : BaseActivityMessage, Mappable {
    /**
     flag to determine if another request can replace the
     */
    public var nonBlocking:Bool?
    
    public init(_ action:String, payload p:String?, nonBlocking nb:Bool = false) {
        super.init(action: action, payload: p)
        nonBlocking = nb
    }
    
    /// :nodoc:
    public required init?(map:Map) {
        super.init(action: "")
    }
    
    /// :nodoc:
    public func mapping(map:Map) {
        action <- map["action"]
        payload <- map["payload"]
        nonBlocking <- map["nonBlocking"]
    }
    
}
