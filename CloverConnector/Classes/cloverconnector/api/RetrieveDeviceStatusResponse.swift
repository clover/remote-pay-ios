//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import ObjectMapper

/**
 response to a retrieve device status request
 */
public class RetrieveDeviceStatusResponse:BaseResponse {

    /// the state of the device
    /// - UNKNOWN
    /// - IDLE
    /// - BUSY
    /// - WAITING_FOR_POS
    /// - WAITING_FOR_CUSTOMER
    ///
    public var state:ExternalDeviceState
    /// optionally contains relevant information for the state
    public var data:ExternalDeviceStateData?
    
    public init(success s: Bool, result r: ResultCode, state:ExternalDeviceState, data:ExternalDeviceStateData?) {
        self.state = state
        self.data = data
        super.init(success: s, result: r)
    }
    /// :nodoc:
    public required init?(map:Map) {
        self.state = .UNKNOWN
        super.init(map: map)
    }
    /// :nodoc:
    public override func mapping(map:Map) {
        super.mapping(map: map)
        self.state <- map["state"]
        self.data <- map["data"]
    }
}


