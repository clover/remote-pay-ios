//  
//  IncrementPreauthResponse.swift
//  CloverConnector
//
//  
//

import Foundation
import ObjectMapper

public class IncrementPreauthResponse: BaseResponse {
    public var authorization: CLVModels.Payments.Authorization?
    
    init(success: Bool, result: ResultCode, authorization: CLVModels.Payments.Authorization?) {
        super.init(success: success, result: result)
        self.authorization = authorization
    }
    
    required public init?(map: Map) {
        super.init(map: map)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        authorization <- map["authorization"]
    }
}
