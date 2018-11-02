//
//  Copyright © 2018 Clover Network, Inc. All rights reserved.
//

import ObjectMapper

/**
 requests the device log a message to the server
 */
public class CloverDeviceLogMessage : Message {
    public var message:String?
    
    init(message:String) {
        self.message = message
        super.init(method: .CLOVER_DEVICE_LOG_REQUEST)
    }
    
    public required init() {
        super.init(method: .CLOVER_DEVICE_LOG_REQUEST)
    }
    
    required public init?(map:Map) {
        super.init(method: .CLOVER_DEVICE_LOG_REQUEST)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        message <- map["message"]
    }
}
