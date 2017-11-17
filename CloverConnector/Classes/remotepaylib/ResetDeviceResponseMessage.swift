//
//  ResetDeviceResponseMessage.swift
//  Pods
//
//
//
import ObjectMapper

public class ResetDeviceResponseMessage:Message {
    public var result:ResultStatus = .FAIL
    public var reason:String?
    public var state:ExternalDeviceState = .UNKNOWN
    
    public init(result r:ResultStatus, reason reas: String?, state s:ExternalDeviceState) {
        result = r
        reason = reas
        state = s
        super.init(method: .RESET_DEVICE_RESPONSE)
    }
    
    public required init?(map:Map) {
        super.init(method: .RESET_DEVICE_RESPONSE)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        result <- map["result"]
        reason <- map["reason"]
        state <- map["state"]
    }
}
