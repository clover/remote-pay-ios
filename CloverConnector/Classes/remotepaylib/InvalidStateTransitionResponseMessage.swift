//  
//  InvalidStateTransitionResponseMessage.swift
//  CloverConnector
//
//  
//

import Foundation
import ObjectMapper

class InvalidStateTransitionResponseMessage: Message {
    var result: ResultStatus?
    var reason: String?
    var requestedTransition: String?
    var state: ExternalDeviceState?
    var substate: ExternalDeviceSubState?
    var data: ExternalDeviceStateData?

    init(result: ResultStatus?, reason: String?, requestedTransition: String?, state: ExternalDeviceState?, substate: ExternalDeviceSubState?, data: ExternalDeviceStateData?) {
        super.init(method: Method.INVALID_STATE_TRANSITION)
        self.result = result
        self.reason = reason
        self.requestedTransition = requestedTransition
        self.state = state
        self.substate = substate
        self.data = data
    }
    
    public required init?(map: Map) {
        super.init(method: .INVALID_STATE_TRANSITION)
        self.result = .FAIL
        self.reason = ""
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        self.result <- map["result"]
        self.reason <- map["reason"]
        self.requestedTransition <- map["requestedTransition"]
        self.state <- map["state"]
        self.substate <- map["substate"]
        self.data <- map["data"]
    }
}
