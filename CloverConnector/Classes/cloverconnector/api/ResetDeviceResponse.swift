//
//  ResetDeviceResponse.swift
//  Pods
//
//
//
import ObjectMapper

public class ResetDeviceResponse:BaseResponse {
    public var state:ExternalDeviceState;
    
    public init(result r:ResultCode, state s: ExternalDeviceState) {
        state = s
        super.init(success: r == .SUCCESS, result: r)
    }
    
    required public init?(_ map: Map) {
        state = .UNKNOWN
        super.init(map)
    }
    
    public override func mapping(map: Map) {
        super.mapping(map)
        self.state <- map["state"]
    }
    
}
