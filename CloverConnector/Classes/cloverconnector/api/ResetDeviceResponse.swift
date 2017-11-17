//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import ObjectMapper

/**
 response to a resetDevice request. It contains the state
 of the device
 */
public class ResetDeviceResponse:BaseResponse {
    public var state:ExternalDeviceState;
    
    public init(result r:ResultCode, state s: ExternalDeviceState) {
        state = s
        super.init(success: r == .SUCCESS, result: r)
    }
    /// :nodoc:
    required public init?(map:Map) {
        state = .UNKNOWN
        super.init(map: map)
    }
    /// :nodoc:
    public override func mapping(map:Map) {
        super.mapping(map: map)
        self.state <- map["state"]
    }
    
}
