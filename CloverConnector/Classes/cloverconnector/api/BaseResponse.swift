//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import ObjectMapper

/**
 A base response for
 */
public class BaseResponse : NSObject, Mappable {
    /// whether the request processed successfully
    public var success:Bool
    /// the result
    /// - SUCCESS -the call succeeded and was successfully queued or processed
    /// - FAIL -the call failed because of some value passed in, or it failed for an unknown reason
    /// - UNSUPPORTED -the capability will never work without a config changed
    /// - CANCEL -this means the call was canceled for some reason, but could work if re-submitted
    /// - ERROR -an unknown error occurred
    public var result:ResultCode
    /// an optional reason for a non-success state
    public var reason:String?
    /// an optional detail message for a non-success state
    public var message:String?
    
    public override init() {
        result = ResultCode.FAIL
        success = false
        super.init()
    }
    
    public init(success:Bool, result:ResultCode) {
        self.success = success
        self.result = result
        super.init()
    }
    
    public init(success:Bool, result:ResultCode, reason:String?, message:String?) {
        self.success = success
        self.result = result
        self.reason = reason
        super.init()
    }
    
    /// :nodoc:
    required public init?(map:Map) {
        self.success = false
        self.result = ResultCode.CANCEL
    }
    
    /// :nodoc:
    public func mapping(map:Map) {
        success <- map["success"]
        result <- map["result"]
        reason <- map["reason"]
        message <- map["message"]
    }
}
