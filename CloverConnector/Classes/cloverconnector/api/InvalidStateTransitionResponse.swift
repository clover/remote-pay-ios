//  
//  InvalidStateTransitionResponse.swift
//  CloverConnector
//
//  
//

import Foundation
import ObjectMapper

public class InvalidStateTransitionResponse: BaseResponse {
    public var requestedTransition: String?
    public var state: ExternalDeviceState?
    public var data: ExternalDeviceStateData?
    
    /// Builds the InvalidStateTransitionResponse
    /// - Parameters:
    ///   - success: If true then the requested operation succeeded
    ///   - result: The result of the requested operation
    ///   - state: The state of the device
    ///   - data: Additional optional relevant information for the state
    init(success: Bool, result: ResultCode, reason: String?, requestedTransition: String?, state: ExternalDeviceState?, data: ExternalDeviceStateData?) {
        super.init(success: success, result: result)
        self.reason = reason
        self.requestedTransition = requestedTransition
        self.state = state
        self.data = data
    }
    
    required public init?(map: Map) {
        super.init(map: map)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        requestedTransition <- map["requestedTransition"]
        state <- map["state"]
        data <- map["data"]
    }
}
