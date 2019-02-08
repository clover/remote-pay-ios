//  
//  DisplayReceiptOptionsResponse.swift
//  CloverConnector
//
//  
//

import Foundation
import ObjectMapper

public class DisplayReceiptOptionsResponse: BaseResponse {
    public var resultStatus: ResultStatus?

    public init(_ status: ResultStatus, reason: String?) {
        super.init()
        self.resultStatus = status
        self.reason = reason
    }
    
    required public init?(map: Map) {
        super.init()
    }
    
    override public func mapping(map:Map) {
        super.mapping(map: map)
        resultStatus <- map["resultStatus"]
    }
}
