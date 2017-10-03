//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import ObjectMapper
/**
 response when a custom activity is finished
 */
public class CustomActivityResponse : BaseResponse {
    /// action name as defined for an Activity
    public var action:String?
    /// a String payload that gets passed in to the start of a custom Activity
    public var payload:String?
    
    init(success s:Bool, result r:ResultCode, action a:String?, payload p:String?) {
        super.init(success: s, result: r)
        self.action = a
        self.payload = p
    }
    /// :nodoc:
    required public init?(map:Map) {
        super.init(map: map)
    }
    /// :nodoc:
    public override func mapping(map:Map) {
        super.mapping(map: map)
        action <- map["action"]
        payload <- map["payload"]
    }
}
