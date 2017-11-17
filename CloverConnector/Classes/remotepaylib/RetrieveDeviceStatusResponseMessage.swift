//
//  RetrieveDeviceStatusResponseMessage.swift
//  Pods
//
//
//

import ObjectMapper

public class RetrieveDeviceStatusResponseMessage:Message {
    
    public var result:ResultStatus
    public var reason:String
    public var state:ExternalDeviceState
    public var subState:ExternalDeviceSubState?
    public var data:ExternalDeviceStateData?
    
    public required init?(map:Map) {
        result = .FAIL
        reason = ""
        state = .UNKNOWN
        super.init(method:.RETRIEVE_DEVICE_STATUS_REQUEST)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        self.result <- map["result"]
        self.reason <- map["reason"]
        self.state <- map["state"]
        self.subState <- map["subState"]
        self.data <- map["data"]
    }
}
