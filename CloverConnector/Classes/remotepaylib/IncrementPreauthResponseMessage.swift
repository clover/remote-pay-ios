//  
//  IncrementPreauthResponseMessage.swift
//  CloverConnector
//
//  
//

import Foundation
import ObjectMapper


/// The response
public class IncrementPreauthResponseMessage: Message {
    public var status: ResultStatus
    public var reason: String?
    public var authorization: CLVModels.Payments.Authorization?
    
    public init(status: ResultStatus, reason: String?, authorization: CLVModels.Payments.Authorization?) {
        self.status = status
        self.reason = reason
        self.authorization = authorization
        super.init(method: .INCREMENT_PREAUTH_RESPONSE)
    }
    
    public required init?(map: Map) {
        self.status = .FAIL
        self.reason = ""
        super.init(method: .INCREMENT_PREAUTH_RESPONSE)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        self.status <- map["status"]
        self.reason <- map["reason"]
        self.authorization <- (map["authorization"], Message.authorizationTransform)
    }
}

