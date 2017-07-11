//
//  RetrieveDeviceStatusResponse.swift
//  Pods
//
//
//
import ObjectMapper

public class RetrieveDeviceStatusResponse:BaseResponse {

    public var state:ExternalDeviceState
    public var data:ExternalDeviceStateData?
    
    public init(success s: Bool, result r: ResultCode, state:ExternalDeviceState, data:ExternalDeviceStateData?) {
        self.state = state
        self.data = data
        super.init(success: s, result: r)
    }
    
    public required init?(_ map: Map) {
        self.state = .UNKNOWN
        super.init(map)
    }
    
    public override func mapping(map: Map) {
        super.mapping(map)
        self.state <- map["state"]
        self.data <- map["data"]
    }
}

public enum QueryStatus:String {
    case FOUND = "FOUND"
    case NOT_FOUND = "NOT_FOUND"
    case IN_PROGRESS = "IN_PROGRESS"
}
